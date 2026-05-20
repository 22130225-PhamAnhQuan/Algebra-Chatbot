from sqlalchemy.orm import Session
from app.models.history import History
from app.models.problem import Problem
from app.models.solution import Solution


class HistoryService:
    @staticmethod
    def get_my_history(db: Session, user_id: int):
        results = db.query(
            History.id,
            History.created_at,
            Problem.content.label("problem_content"),
            Problem.input_type,
            Solution.result,
            Solution.steps,
            Solution.latex
        ).outerjoin(Problem, History.problem_id == Problem.id) \
            .outerjoin(Solution, History.solution_id == Solution.id) \
            .filter(History.user_id == user_id) \
            .order_by(History.created_at.desc()) \
            .all()

        return [
            {
                "id": r.id,
                "created_at": r.created_at,
                "problem_content": r.problem_content,
                "input_type": r.input_type,
                "result": r.result,
                "steps": r.steps,
                "latex": r.latex,
            }
            for r in results
        ]

    @staticmethod
    def delete_history_item(db: Session, history_id: int, user_id: int):
        """Xóa một bản ghi lịch sử của người dùng cụ thể"""
        # Tìm đúng bản ghi thuộc về user đó để tránh xóa nhầm của người khác
        item = db.query(History).filter(
            History.id == history_id,
            History.user_id == user_id
        ).first()

        if item:
            try:
                db.delete(item)
                db.commit()
                return True
            except Exception as e:
                db.rollback()
                print(f"Lỗi khi xóa DB: {e}")
                return False
        return False