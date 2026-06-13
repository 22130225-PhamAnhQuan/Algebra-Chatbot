from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db

from app.models.message import Message
from app.models.conversation import Conversation
from app.core.dependencies import get_current_user
from app.models.user import User

from app.schemas.chat import CreateConversationRequest, SendMessageRequest, MessageResponse
from app.services.ai_service import generate_ai_response

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("/conversation")
def create_conversation(
        request: CreateConversationRequest,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    conversation = Conversation(
        user_id=current_user.id,
        problem_id=request.problem_id,
        title="Trò chuyện giải toán"
    )
    db.add(conversation)
    db.commit()
    db.refresh(conversation)
    return conversation


@router.post("/send")
def send_message(
        request: SendMessageRequest,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # 1. Gọi AI lấy phản hồi trước
    ai_response = generate_ai_response(
        db=db,
        conversation_id=request.conversation_id,
        question=request.message
    )

    # 2. Kiểm tra nếu AI trả về thông báo lỗi hệ thống thì không lưu vào DB
    if "lỗi" in ai_response.lower() or "không khả dụng" in ai_response.lower():
        return {"response": ai_response}

    # 3. Nếu AI xử lý thành công, lưu cả tin nhắn của User và AI vào DB
    user_message = Message(
        conversation_id=request.conversation_id,
        role="user",
        content=request.message
    )
    bot_message = Message(
        conversation_id=request.conversation_id,
        role="assistant",
        content=ai_response
    )

    db.add(user_message)
    db.add(bot_message)
    db.commit()

    return {"response": ai_response}


@router.get("/messages/{conversation_id}", response_model=list[MessageResponse])
def get_messages(
        conversation_id: int,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id)
        .order_by(Message.created_at.asc())
        .all()
    )
    return messages