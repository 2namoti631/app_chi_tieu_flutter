from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder
from typing import List
from schemas import *
from crud import *
import hashlib
from datetime import datetime
from configrations import *

app = FastAPI()

# CORS cho frontend gọi API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------ TRANSACTIONS ------------------

@app.post("/transactions/")
def create(transaction: Transaction):
    try:
        data = jsonable_encoder(transaction)
        if 'date' in data and isinstance(data['date'], str):
            data['date'] = datetime.fromisoformat(data['date'])
        new_trans = create_transaction(data)
        return serialize(new_trans)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/transactions/{transaction_id}")
def read(transaction_id: str):
    trans = get_transaction(transaction_id)
    if not trans:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return serialize(trans)


@app.get("/transactions/user/{user_id}")
def get_transactions_by_user(user_id: str):
    transactions = get_transactions_for_user(user_id)
    return transactions  # đã serialize ở crud



@app.put("/transactions/{transaction_id}")
def update(transaction_id: str, transaction: Transaction):
    data = jsonable_encoder(transaction)
    updated = update_transaction(transaction_id, data)
    if not updated:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return updated


@app.delete("/transactions/{transaction_id}")
def delete(transaction_id: str):
    deleted = delete_transaction(transaction_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return {"message": "Transaction deleted"}

@app.get("/transactions/")
def get_transactions(user_id: str = Query(...), date: date = Query(...)):
    date_str = date.strftime('%Y-%m-%d')

    results = list(transaction_collection.find({
        "user_id": user_id,
        "date": date_str
    }))

    for r in results:
        r["_id"] = str(r["_id"])
    return results



@app.get("/transactions/all-for-user", response_model=List[dict])
async def get_transactions(userId: str = Query(...)):
    result = []
    transactions = await transaction_collection.find({"user_id": userId}).to_list(length=100)

    for t in transactions:
        for item in t["items"]:
            result.append({
                "amount": item["amount"],
                "type": item["type"],
                "category": item["category"],
                "note": item.get("note", ""),
                "date": t["date"],
                "userId": t["user_id"]
            })
    return result


# ------------------ USERS ------------------

@app.post("/users/", response_model=UserInDB)
def create_user_api(user: User):
    if get_user_by_email(user.email):
        raise HTTPException(status_code=400, detail="User already exists")

    user_data = jsonable_encoder(user)
    raw_password = user_data.pop("password")
    user_data["password_hash"] = hashlib.sha256(raw_password.encode()).hexdigest()
    user_data["created_at"] = datetime.utcnow()

    return create_user(user_data)


@app.post("/login")
def login(user: UserLogin):
    db_user = get_user_by_email(user.email)
    if not db_user:
        raise HTTPException(status_code=401, detail="User not found")

    hashed_input = hashlib.sha256(user.password.encode()).hexdigest()
    if hashed_input != db_user["password_hash"]:
        raise HTTPException(status_code=401, detail="Mật khẩu sai")

    return {"userId": str(db_user["_id"])}


# ------------------ CATEGORIES ------------------

@app.post("/categories/")
def create_category_api(category: Category):
    return create_category(jsonable_encoder(category))


@app.get("/categories/{user_id}")
def get_user_categories(user_id: str):
    return get_categories_by_user(user_id)


@app.put("/categories/{category_id}")
def update_categories(category_id: str, updated: CategoryUpdate):
    data = {k: v for k, v in updated.dict().items() if v is not None}
    if not data:
        raise HTTPException(status_code=400, detail="Không có dữ liệu cập nhật")

    updated_doc = update_category(category_id, data)
    if not updated_doc:
        raise HTTPException(status_code=404, detail="Không tìm thấy category")
    return updated_doc


@app.delete("/categories/{cat_id}", summary="Delete Category")
def delete_category_api(cat_id: str):
    if delete_category(cat_id):
        return {"message": "Deleted successfully"}
    raise HTTPException(status_code=404, detail="Category not found")


# -------- Analytics ------------
@app.get("/analytics/")
def get_analytics(
    user_id: str = Query(...),
    filter_by: str = Query(..., enum=["week", "month", "year"]),
    reference_date: Optional[datetime] = Query(default=None)
):
    if reference_date is None:
        reference_date = datetime.now()

    start, end = get_date_range(filter_by, reference_date)

    # Lấy danh sách transactions
    transactions = list(transaction_collection.find({
        "user_id": user_id,
        "date": {"$gte": start, "$lte": end}
    }))

    # Tính tổng chi tiêu bằng pipeline unwind
    pipeline = [
        {"$match": {
            "user_id": user_id,
            "date": {"$gte": start, "$lte": end}
        }},
        {"$unwind": "$items"},
        {"$match": {"items.type": "expense"}},
        {"$group": {
            "_id": None,
            "total_spent": {"$sum": "$items.amount"}
        }}
    ]

    total_result = list(transaction_collection.aggregate(pipeline))
    total_spent = total_result[0]["total_spent"] if total_result else 0

    # Chuyển _id thành string và date thành chuỗi
    for t in transactions:
        t["_id"] = str(t["_id"])
        if isinstance(t["date"], datetime):
            t["date"] = t["date"].strftime("%Y-%m-%d")

    return {
        "filter_by": filter_by,
        "start_date": start.isoformat(),
        "end_date": end.isoformat(),
        "total_spent": total_spent,
        "transactions": transactions
    }
