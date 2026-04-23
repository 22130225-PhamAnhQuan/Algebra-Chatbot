from sqlalchemy.orm import Session
from app.models.message import Message
from app.models.conversation import Conversation
from app.models.solution import Solution
from app.services.solver.ai_solver import AISolver
from app.core.prompts import AIPrompts


class ChatService:
    @classmethod
    async def send_message(cls, db: Session, conversation_id: int, user_message: str):
        # 1. Lấy thông tin hội thoại và bài toán liên quan
        conv = db.query(Conversation).filter(Conversation.id == conversation_id).first()

        # 2. Lấy lời giải cũ để làm ngữ cảnh (Context)
        context_solution = ""
        if conv.problem_id:
            sol = db.query(Solution).filter(Solution.problem_id == conv.problem_id).first()
            if sol:
                context_solution = f"Đề bài: {conv.problem.content}. Lời giải: {sol.steps}"

        # 3. Tạo Prompt hỏi đáp dựa trên ngữ cảnh
        prompt = AIPrompts.CHATBOT_EXPLAIN.format(
            problem_content=conv.problem.content if conv.problem else "Hỏi đáp chung",
            solution_steps=context_solution,
            user_question=user_message
        )

        # 4. Gọi Phi-3 Mini trả lời (dùng lại hàm call_phi3 của AISolver cho gọn)
        # Lưu ý: Với chatbot thường trả về text nên ta không ép format JSON ở đây
        ai_response = await AISolver.call_phi3_text_only(prompt)

        # 5. Lưu tin nhắn vào Database [cite: 39]
        db.add(Message(conversation_id=conversation_id, sender="USER", content=user_message))
        db.add(Message(conversation_id=conversation_id, sender="BOT", content=ai_response))
        db.commit()

        return ai_response