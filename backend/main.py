from fastapi import FastAPI, HTTPException
from schemas import *
from fastapi.encoders import jsonable_encoder
from crud import *

app = FastAPI()
# ------------------ TRANSACTIONS ------------------
@app.post("/transactions/")
def create(transaction: Transaction):
    try:
        data = jsonable_encoder(transaction)
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

@app.get("/transactions/")
def read_all():
    transactions = get_all_transactions()
    return [serialize(t) for t in transactions]

@app.put("/transactions/{transaction_id}")
def update(transaction_id: str, transaction: Transaction):
    data = jsonable_encoder(transaction)
    updated = update_transaction(transaction_id, data)
    if not updated:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return serialize(updated)

@app.delete("/transactions/{transaction_id}")
def delete(transaction_id: str):
    deleted_count = delete_transaction(transaction_id)
    if deleted_count == 0:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return {"message": "Transaction deleted"}


# ------------------ USERS ------------------
@app.post("/users/")
def create_user_api(user: User):
    if get_user_by_email(user.email):
        raise HTTPException(status_code=400, detail="User already exists")
    return create_user(jsonable_encoder(user))


# ------------------ CATEGORIES ------------------
@app.post("/categories/")
def create_category_api(category: Category):
    return create_category(jsonable_encoder(category))


@app.get("/categories/{user_id}")
def get_user_categories(user_id: str):
    return get_categories_by_user(user_id)


@app.delete("/categories/{cat_id}",summary="Delete Category")
def delete_category_api(cat_id: str):
    if delete_category(cat_id):
        return {"message": "Deleted successfully"}
    raise HTTPException(status_code=404, detail="Category not found")
