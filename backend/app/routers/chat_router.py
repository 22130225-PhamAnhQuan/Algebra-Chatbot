from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.services.chat_service import ChatService
from app.schemas.chat import MessageCreate, MessageResponse
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("/send", response_model=None)
async def send_chat_message(
        payload: MessageCreate,
        db: Session = Depends(get_db),
        current_user=Depends(get_current_user)
):
    try:
        # Gọi service để xử lý hỏi đáp AI dựa trên ngữ cảnh
        response_content = await ChatService.send_message(
            db=db,
            conversation_id=payload.conversation_id,
            user_message=payload.content
        )

        return {
            "status": "success",
            "bot_response": response_content
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))