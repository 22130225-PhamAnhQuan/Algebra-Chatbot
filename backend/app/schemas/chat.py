from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

# --- MESSAGE SCHEMAS ---
class MessageCreate(BaseModel):
    conversation_id: int
    content: str
    type: Optional[str] = "text"

class MessageResponse(BaseModel):
    id: int
    conversation_id: int
    sender: str
    content: str
    type: str
    created_at: datetime

    class Config:
        from_attributes = True # Dùng cho SQLAlchemy bản mới

# --- CONVERSATION SCHEMAS ---
class ConversationCreate(BaseModel):
    problem_id: int
    title: Optional[str] = "Giải toán Đại số"

class ConversationResponse(BaseModel):
    id: int
    user_id: int
    problem_id: Optional[int]
    title: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Response bao gồm cả lịch sử tin nhắn
class ConversationDetailResponse(ConversationResponse):
    messages: List[MessageResponse] = []