from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List, Literal
from datetime import datetime, date


# ------------------ USERS ------------------
class User(BaseModel):
    email: EmailStr
    name: str
    password_hash: str 
    created_at: datetime = Field(default_factory=datetime.utcnow) 

# ------------------ CATEGORIES ------------------
class Category(BaseModel):
    user_id: str  # sẽ là ObjectId dạng string
    name: str
    icon: Optional[str] = "📦"  # có thể dùng emoji icon
    color: Optional[str] = "#A22727"  # mã màu hex
    type: Literal["expense", "income"]  # chỉ cho phép 2 loại
    created_at: datetime = Field(default_factory=datetime.utcnow)

# ------------------ TRANSACTIONS ------------------
class TransactionItem(BaseModel):

    amount: int  
    type: str 
    category: str
    note: Optional[str] = ""


class Transaction(BaseModel):
    user_id: str 
    date: date # ngày chi tiêu do người dùng chọn 
    items: List[TransactionItem]
    createAt: datetime = Field(default_factory=datetime.utcnow) # thời điểm tạo bản ghi 

