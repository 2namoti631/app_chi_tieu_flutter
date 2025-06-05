from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List, Literal
from datetime import datetime, date


# ------------------ USERS ------------------
class User(BaseModel):
    email: EmailStr
    name: str
    password: str = Field(..., min_length=6)  # plaintext password client gửi khi đăng ký
    created_at: datetime = Field(default_factory=datetime.utcnow)
    class Config:
        orm_mode = True

class UserInDB(BaseModel):
    email: EmailStr
    name: str
    password_hash: str  # chỉ lưu hash mật khẩu, không lưu plaintext
    created_at: datetime
    class Config:
        orm_mode = True


# ------------------ LOGIN ------------------
class UserLogin(BaseModel):
    email: EmailStr
    password: str  # plaintext password client gửi khi đăng nhập

# ------------------ CATEGORIES ------------------
class Category(BaseModel):
    user_id: str  # ObjectId dạng string
    name: str
    icon: Optional[str] = "📦"
    type: Literal["expense", "income"]
    created_at: datetime = Field(default_factory=datetime.utcnow)

class CategoryUpdate(BaseModel):
    name: Optional[str]
    icon: Optional[str]
    type: Optional[Literal["expense", "income"]]

# ------------------ TRANSACTIONS ------------------

class TransactionItem(BaseModel):

    amount: int  
    type: str 
    category: str
    note: Optional[str] = ""


class Transaction(BaseModel):

    user_id: str 
    date: date
    items: List[TransactionItem]
    created_at: datetime = Field(default_factory=datetime.utcnow)
