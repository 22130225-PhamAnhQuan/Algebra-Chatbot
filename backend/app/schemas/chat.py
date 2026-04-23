from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional


class MessageBase(BaseModel):
    content: str
    sender: str # 'USER' hoặc 'BOT'

class MessageCreate(MessageBase):
    conversation_id: int

class MessageResponse(MessageBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class ConversationResponse(BaseModel):
    id: int
    title: Optional[str]
    created_at: datetime
    messages: List[MessageResponse] = []

    class Config:
        from_attributes = True