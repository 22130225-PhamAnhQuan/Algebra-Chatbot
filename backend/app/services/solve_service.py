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

        raw_steps = solution_data.get('steps', [])

        # 2. Ép kiểu từng phần tử về chuỗi (đề phòng AI trả về dict)
        formatted_steps = []
        for step in raw_steps:
            if isinstance(step, str):
                formatted_steps.append(step)
            elif isinstance(step, dict):
                # Nếu là dict, lấy giá trị đầu tiên của nó
                val = list(step.values())[0] if step.values() else ""
                formatted_steps.append(str(val))
            else:
                formatted_steps.append(str(step))

        # 3. Lưu Solution với danh sách đã chuẩn hóa
        new_solution = Solution(
            problem_id=new_problem.id,
            result=str(solution_data.get('result', '')),
            steps="|".join(formatted_steps),  # Nối các chuỗi an toàn bằng dấu |
            latex=solution_data.get('latex', ''),
            model="phi3-mini + sympy"
        )
        # ---------------------------------------

        db.add(new_solution)
        db.flush()

        # Lưu History & Log
        db.add(History(user_id=user_id, problem_id=new_problem.id, solution_id=new_solution.id))
        db.add(AILog(
            user_id=user_id, problem_id=new_problem.id,
            input=raw_text, output=str(solution_data.get('result', '')),
            latency_ms=latency, status="success"
        ))

        db.commit()
        return solution_data