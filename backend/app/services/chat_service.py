import httpx
import json
from sqlalchemy.orm import Session
from app.models.conversation import Conversation
from app.models.message import Message
from app.schemas.chat import MessageCreate, ConversationCreate
from app.core.config import OLLAMA_URL


class ChatService:
    @staticmethod
    async def init_conversation(db: Session, user_id: int, data: ConversationCreate):
        new_conv = Conversation(
            user_id=user_id,
            problem_id=data.problem_id,
            title=data.title
        )
        db.add(new_conv)
        db.commit()
        db.refresh(new_conv)
        return new_conv

    @staticmethod
    async def create_message(db: Session, sender: str, conversation_id: int, content: str, msg_type: str):
        new_msg = Message(
            conversation_id=conversation_id,
            sender=sender,
            content=content,
            type=msg_type
        )
        db.add(new_msg)
        db.commit()
        db.refresh(new_msg)
        return new_msg

    @staticmethod
    async def get_ai_response(db: Session, conversation_id: int, user_content: str):
        # 1. Lấy lịch sử để hiểu ngữ cảnh
        history = db.query(Message).filter(Message.conversation_id == conversation_id) \
            .order_by(Message.created_at.desc()).limit(6).all()

        context = ""
        for m in reversed(history):
            role = "User" if m.sender == "USER" else "Assistant"
            context += f"{role}: {m.content}\n"

        # 2. Thiết kế System Prompt để AI trả về đúng định dạng mình muốn
        system_instructions = (
            "Bạn là một gia sư toán chuyên nghiệp. "
            "Hãy giải thích ngắn gọn, dễ hiểu. "
            "BẮT BUỘC dùng ký hiệu LaTeX (ví dụ: $x^2$, $\\frac{a}{b}$) cho mọi công thức toán học."
        )

        full_prompt = f"{system_instructions}\n\nLịch sử:\n{context}\nHọc sinh: {user_content}\nAI:"

        # 3. Gọi Ollama API thật
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{OLLAMA_URL}",
                    json={
                        "model": "phi3",  # Hoặc model bạn đang chạy
                        "prompt": full_prompt,
                        "stream": False  # Tắt stream để nhận nguyên cụm JSON cho dễ xử lý
                    }
                )

                if response.status_code == 200:
                    result = response.json()
                    return result.get("response", "Xin lỗi, mình không thể xử lý câu hỏi này.")
                else:
                    return f"Lỗi kết nối AI (Mã lỗi: {response.status_code})"

        except Exception as e:
            print(f"Error calling Ollama: {e}")
            return "Máy chủ AI đang bận, bạn thử lại sau nhé!"