from configrations import *
from bson import ObjectId
from datetime import datetime, timedelta
from schemas import * 
# ------------------ COMMON ------------------

def serialize(doc):
    doc["_id"] = str(doc["_id"])
    return doc

# ------------------ TRANSACTIONS ------------------

def get_transactions_for_user(user_id: str):
    return [serialize(tx) for tx in transaction_collection.find({"user_id": user_id})]

def create_transaction(transaction_data: dict):
    result = transaction_collection.insert_one(transaction_data)
    return serialize(transaction_collection.find_one({"_id": result.inserted_id}))

def get_transaction(transaction_id: str):
    tx = transaction_collection.find_one({"_id": ObjectId(transaction_id)})
    return serialize(tx) if tx else None

def get_all_transactions():
    return [serialize(tx) for tx in transaction_collection.find()]

def update_transaction(transaction_id: str, updated_data: dict):
    transaction_collection.update_one({"_id": ObjectId(transaction_id)}, {"$set": updated_data})
    return serialize(transaction_collection.find_one({"_id": ObjectId(transaction_id)}))

def delete_transaction(transaction_id: str):
    result = transaction_collection.delete_one({"_id": ObjectId(transaction_id)})
    return result.deleted_count > 0

# ------------------ USERS ------------------

def get_user_by_email(email: str):
    user = user_collection.find_one({"email": email})
    return serialize(user) if user else None

def create_user(user_data: dict):
    result = user_collection.insert_one(user_data)
    return serialize(user_collection.find_one({"_id": result.inserted_id}))

# ------------------ CATEGORIES ------------------

def create_category(data: dict):
    result = category_collection.insert_one(data)
    return serialize(category_collection.find_one({"_id": result.inserted_id}))

def get_categories_by_user(user_id: str):
    return [serialize(cat) for cat in category_collection.find({"user_id": user_id})]

def update_category(category_id: str, updated_data: dict):
    category_collection.update_one({"_id": ObjectId(category_id)}, {"$set": updated_data})
    return serialize(category_collection.find_one({"_id": ObjectId(category_id)}))

def delete_category(cat_id: str):
    result = category_collection.delete_one({"_id": ObjectId(cat_id)})
    return result.deleted_count > 0



def transaction_to_mongo_doc(transaction: Transaction):
    mongo_date = datetime.combine(transaction.date, datetime.min.time())  # date -> datetime 00:00:00
    return {
        "user_id": transaction.user_id,
        "date": mongo_date,
        "items": [item.dict() for item in transaction.items],
        "created_at": transaction.created_at
    }


def get_date_range(filter_by: str, ref_date: datetime):
    # Helper để đặt thời gian đầu ngày
    def start_of_day(dt):
        return datetime(dt.year, dt.month, dt.day, 0, 0, 0, 0)



    # Helper để đặt thời gian cuối ngày
    def end_of_day(dt):
        return datetime(dt.year, dt.month, dt.day, 23, 59, 59, 999999)

    if filter_by == "week":
        start = start_of_day(ref_date - timedelta(days=ref_date.weekday()))  # Monday đầu tuần
        end = end_of_day(start + timedelta(days=6))  # Chủ nhật cuối tuần
    elif filter_by == "month":
        start = start_of_day(datetime(ref_date.year, ref_date.month, 1))
        if ref_date.month == 12:
            end = end_of_day(datetime(ref_date.year, 12, 31))
        else:
            # Lấy ngày cuối tháng: ngày 1 tháng sau trừ 1 ngày
            next_month_start = datetime(ref_date.year, ref_date.month + 1, 1)
            end = end_of_day(next_month_start - timedelta(days=1))
    elif filter_by == "year":
        start = start_of_day(datetime(ref_date.year, 1, 1))
        end = end_of_day(datetime(ref_date.year, 12, 31))
    else:
        raise ValueError("Invalid filter_by")

    return start, end