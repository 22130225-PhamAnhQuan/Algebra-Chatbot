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

        # 1. Xử lý OCR nếu người dùng gửi ảnh
        if image_bytes:
            input_type = "image"
            # Sử dụng EasyOCR đã nâng cấp
            raw_text = await OcrService.extract_text_from_image(image_bytes)

        # 2. Giải toán qua AI Pipeline (Trả về JSON có grade, steps, result, latex)
        solution_data = await AISolver.solve(raw_text)
        latency = int((time.time() - start_time) * 1000)

        # 3. Lưu vào Database (PostgreSQL)
        # Lưu Problem: Thêm thông tin khối lớp vào content nếu muốn (tùy chọn)
        grade = solution_data.get('grade', 'Chưa xác định')
        new_problem = Problem(
            user_id=user_id,
            content=raw_text,
            input_type=input_type
        )
        db.add(new_problem)
        db.flush()

        # Chuẩn hóa steps (giữ logic ép kiểu chuỗi an toàn của bạn)
        raw_steps = solution_data.get('steps', [])
        formatted_steps = []
        for step in raw_steps:
            if isinstance(step, str):
                formatted_steps.append(step)
            elif isinstance(step, dict):
                val = list(step.values())[0] if step.values() else ""
                formatted_steps.append(str(val))
            else:
                formatted_steps.append(str(step))

        # 4. Lưu Solution
        # Mình bổ sung thêm thông tin Grade vào phần model để sau này dễ thống kê
        new_solution = Solution(
            problem_id=new_problem.id,
            result=str(solution_data.get('result', '')),
            steps="|".join(formatted_steps),
            latex=solution_data.get('latex', ''),
            model=f"phi3-mini (Lớp {grade}) + sympy"  # Lưu vết lớp mấy
        )

        db.add(new_solution)
        db.flush()

        # 5. Lưu History & Log
        db.add(History(user_id=user_id, problem_id=new_problem.id, solution_id=new_solution.id))
        db.add(AILog(
            user_id=user_id,
            problem_id=new_problem.id,
            input=raw_text,
            output=str(solution_data.get('result', '')),
            latency_ms=latency,
            status="success"
        ))

        db.commit()

        # Trả về đầy đủ dữ liệu cho Frontend (bao gồm cả grade để Flutter hiển thị)
        return solution_data