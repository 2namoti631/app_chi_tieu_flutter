from configrations import *
from bson import ObjectId

def serialize(doc):
    doc["_id"] = str(doc["_id"])
    return doc

# ------------------ TRANSACTIONS ------------------


# CREATE
def create_transaction(transaction_data):
    result = transaction_collection.insert_one(transaction_data)
    return serialize(transaction_collection.find_one({"_id": result.inserted_id}))

# READ
def get_transaction(transaction_id):
    return serialize(transaction_collection.find_one({"_id": ObjectId(transaction_id)}))

# READ ALL
def get_all_transactions():
    return [serialize(t) for t in transaction_collection.find()]

# UPDATE
def update_transaction(transaction_id, updated_data):
    transaction_collection.update_one({"_id": ObjectId(transaction_id)}, {"$set": updated_data})
    return serialize(transaction_collection.find_one({"_id": ObjectId(transaction_id)}))

# DELETE
def delete_transaction(transaction_id):
    result = transaction_collection.delete_one({"_id": ObjectId(transaction_id)})
    return result.deleted_count




# ------------------ USERS ------------------

def create_user(user_data: dict):
    result = user_collection.insert_one(user_data)
    return serialize(user_collection.find_one({"_id": result.inserted_id}))


def get_user_by_email(email: str):
    user = user_collection.find_one({"email": email})
    return serialize(user) if user else None



# ------------------ CATEGORIES ------------------

def create_category(data: dict):
    result = category_collection.insert_one(data)
    return serialize(category_collection.find_one({"_id": result.inserted_id}))


def get_categories_by_user(user_id: str):
    return [serialize(cat) for cat in category_collection.find({"user_id": user_id})]


def delete_category(cat_id: str):
    result = category_collection.delete_one({"_id": ObjectId(cat_id)})
    return result.deleted_count > 0