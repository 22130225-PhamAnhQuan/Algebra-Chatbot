import json
from app.models.problem import Problem
from app.models.solution import Solution
from app.models.conversation import Conversation
from app.models.message import Message

def build_context(db, conversation_id: int, limit: int = 15):
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conversation:
        return None

    problem = db.query(Problem).filter(Problem.id == conversation.problem_id).first()
    solution = db.query(Solution).filter(Solution.problem_id == problem.id).first()

    solution_text = "Chưa có lời giải"
    if solution and solution.steps:
        try:
            steps_list = json.loads(solution.steps)
            solution_text = "\n".join(steps_list) if isinstance(steps_list, list) else str(solution.steps)
        except Exception:
            solution_text = str(solution.steps)

    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id)
        .order_by(Message.created_at.asc())
        .limit(limit)
        .all()
    )

    history = [{"role": msg.role, "content": msg.content} for msg in messages]

    return {
        "problem": problem.content if problem else "Không có dữ liệu",
        "solution": solution_text,
        "history": history
    }