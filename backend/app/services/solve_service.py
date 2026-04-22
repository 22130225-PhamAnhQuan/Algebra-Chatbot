import time
from sqlalchemy.orm import Session
from app.models import Problem, Solution, History, AILog


class SolverService:
    @staticmethod
    def solve_and_record(db: Session, user_id: int, content: str, input_type: str, image_url: str = None):
        start_time = time.time()

        # 1. Lưu Problem
        db_problem = Problem(
            user_id=user_id,
            content=content,
            input_type=input_type,
            image_url=image_url
        )
        db.add(db_problem)
        db.commit()
        db.refresh(db_problem)

        # 2. Gọi AI (Giả lập - Quan thay bằng gọi Gemini API thật nhé)
        # Output mong muốn từ AI: Kết quả cuối, Các bước, và mã Latex
        ai_response = {
            "result": "x = 1/2; x = -3",
            "steps": [
                "Xác định hệ số: a = 2, b = 5, c = -3",
                "Tính biệt thức delta: Δ = b² - 4ac = 5² - 4.2.(-3) = 49",
                "Vì Δ > 0, phương trình có hai nghiệm phân biệt",
                "Áp dụng công thức nghiệm ta được x₁ = 1/2 và x₂ = -3"
            ],
            "latex": r"x = \frac{-b \pm \sqrt{\Delta}}{2a}",
            "tokens": 150
        }

        # 3. Lưu Solution
        db_solution = Solution(
            problem_id=db_problem.id,
            result=ai_response["result"],
            steps="|".join(ai_response["steps"]),  # Gộp mảng thành chuỗi để lưu
            latex=ai_response["latex"],
            model="gemini-1.5-flash"
        )
        db.add(db_solution)
        db.commit()
        db.refresh(db_solution)

        # 4. Lưu History (Để Quan hiện ở màn Lịch sử)
        db_history = History(
            user_id=user_id,
            problem_id=db_problem.id,
            solution_id=db_solution.id
        )
        db.add(db_history)

        # 5. Ghi AI Log (Dùng cho báo cáo thống kê latency/token)
        latency = int((time.time() - start_time) * 1000)
        db_log = AILog(
            user_id=user_id,
            problem_id=db_problem.id,
            input=content,
            output=ai_response["result"],
            model="gemini-1.5-flash",
            latency_ms=latency,
            status="success",
            tokens_used=ai_response["tokens"]
        )
        db.add(db_log)

        db.commit()

        return {
            "problem": db_problem,
            "solution": db_solution,
            "steps_list": ai_response["steps"]  # Trả về list cho Flutter dễ hiện
        }