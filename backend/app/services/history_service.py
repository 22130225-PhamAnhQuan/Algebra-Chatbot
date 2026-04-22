from sqlalchemy.orm import Session
from app.models.history import History
from app.models.problem import Problem
from app.models.solution import Solution


class HistoryService:
    @staticmethod
    def get_my_history(db: Session, user_id: int):
        """
        Lấy lịch sử giải bài của Quan.
        Kết hợp (Join) 3 bảng để lấy đủ nội dung đề và giải.
        """
        results = db.query(
            History.id,
            History.created_at,
            Problem.content.label("problem_content"),
            Problem.input_type,
            Solution.result,
            Solution.steps,
            Solution.latex
        ).join(Problem, History.problem_id == Problem.id) \
            .join(Solution, History.solution_id == Solution.id) \
            .filter(History.user_id == user_id) \
            .order_by(History.created_at.desc()) \
            .all()

        return results

    @staticmethod
    def delete_history_item(db: Session, history_id: int, user_id: int):
        """Xóa 1 dòng lịch sử nhưng giữ lại dữ liệu gốc nếu cần"""
        item = db.query(History).filter(
            History.id == history_id,
            History.user_id == user_id
        ).first()

        if item:
            db.delete(item)
            db.commit()
            return True
        return False