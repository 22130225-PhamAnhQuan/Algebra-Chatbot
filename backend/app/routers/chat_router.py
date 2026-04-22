from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.models import Message, Conversation, Problem, Solution
from app.services.ai_service import solve_math

router = APIRouter(prefix="/chat", tags=["Chat"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/send")
def send_message(conversation_id: int, message: str, db: Session = Depends(get_db)):

    # 1. Lưu USER message
    user_msg = Message(
        conversation_id=conversation_id,
        sender="USER",
        content=message
    )
    db.add(user_msg)
    db.commit()

    # 2. Tạo problem
    problem = Problem(
        user_id=1,  # TODO: thay bằng auth user
        content=message
    )
    db.add(problem)
    db.commit()
    db.refresh(problem)

    # 3. AI solve
    result = solve_math(message)

    # 4. Lưu solution
    solution = Solution(
        problem_id=problem.id,
        result=result.get("result"),
        steps=result.get("steps"),
        model="sympy"
    )
    db.add(solution)
    db.commit()

    # 5. Lưu BOT message
    bot_msg = Message(
        conversation_id=conversation_id,
        sender="BOT",
        content=result.get("steps", "Lỗi AI")
    )
    db.add(bot_msg)
    db.commit()

    return {
        "user_message": message,
        "bot_response": bot_msg.content
    }