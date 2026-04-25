from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.chat import (
    ConversationCreate, ConversationResponse,
    MessageCreate, MessageResponse, ConversationDetailResponse
)
from app.services.chat_service import ChatService
from app.models.conversation import Conversation

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.post("/init", response_model=ConversationResponse)
async def init_chat(data: ConversationCreate, db: Session = Depends(get_db)):
    # user_id này sau này sẽ lấy từ Token JWT
    user_id = 1
    return await ChatService.init_conversation(db, user_id, data)

@router.post("/send", response_model=MessageResponse)
async def send_message(data: MessageCreate, db: Session = Depends(get_db)):
    # 1. Lưu tin nhắn của người dùng
    await ChatService.create_message(
        db, sender="USER", conversation_id=data.conversation_id,
        content=data.content, msg_type=data.type
    )

    # 2. Lấy câu trả lời từ AI
    ai_content = await ChatService.get_ai_response(db, data.conversation_id, data.content)

    # 3. Lưu và trả về tin nhắn của AI (Bot)
    return await ChatService.create_message(
        db, sender="BOT", conversation_id=data.conversation_id,
        content=ai_content, msg_type="latex"
    )

@router.get("/history/{conversation_id}", response_model=ConversationDetailResponse)
async def get_history(conversation_id: int, db: Session = Depends(get_db)):
    conv = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conv:
        raise HTTPException(status_code=404, detail="Không tìm thấy cuộc trò chuyện")
    return conv