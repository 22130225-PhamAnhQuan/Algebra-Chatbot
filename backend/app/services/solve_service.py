from sqlalchemy.orm import Session
from app.services.solver.ai_solver import AISolver
from app.services.ocr_service import OcrService
from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History
from app.models.ai_log import AILog
import time


class SolveService:
    @classmethod
    async def handle_math_solving(
            cls, db: Session, user_id: int, text: str = None, image_bytes: bytes = None
    ):
        start_time = time.time()
        input_type = "text"
        raw_text = text

        # 1. Xử lý OCR nếu có ảnh [cite: 11, 16, 23]
        if image_bytes:
            input_type = "image"
            raw_text = await OcrService.extract_text_from_image(image_bytes)

        # 2. Giải toán qua AI Pipeline [cite: 10, 15, 36]
        solution_data = await AISolver.solve(raw_text)
        latency = int((time.time() - start_time) * 1000)

        # 3. Lưu vào Database (PostgreSQL) [cite: 18, 29, 37]
        # Lưu Problem
        new_problem = Problem(user_id=user_id, content=raw_text, input_type=input_type)
        db.add(new_problem)
        db.flush()  # Để lấy ID

        # Lưu Solution [cite: 18, 29]
        new_solution = Solution(
            problem_id=new_problem.id,
            result=solution_data['result'],
            steps="|".join(solution_data['steps']),
            latex=solution_data['latex'],
            model="phi3-mini + sympy"
        )
        db.add(new_solution)
        db.flush()

        # Lưu History & Log [cite: 18, 19]
        db.add(History(user_id=user_id, problem_id=new_problem.id, solution_id=new_solution.id))
        db.add(AILog(
            user_id=user_id, problem_id=new_problem.id,
            input=raw_text, output=solution_data['result'],
            latency_ms=latency, status="success"
        ))

        db.commit()
        return solution_data