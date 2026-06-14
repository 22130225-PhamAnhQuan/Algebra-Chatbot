from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, Form
from sqlalchemy.orm import Session
import shutil
import uuid
import os
import json
import logging

from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User

from app.services.solve_service import solve_math
from app.services.ocr_service import OCRService

from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History
from app.schemas.solve import SolveRequest

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/solver", tags=["solver"])
ocr_service = OCRService()


def save_solution_to_db(
        db: Session,
        user_id: int,
        content: str,
        result: dict,
        input_type: str,
        grade_id: int,
        chapter_id: int,
        lesson_id: int,
        image_url: str = None
):
    try:
        # 1. Lưu Đề bài
        problem = Problem(
            user_id=user_id,
            grade_id=grade_id,
            chapter_id=chapter_id,
            lesson_id=lesson_id,
            content=content,
            input_type=input_type,
            image_url=image_url
        )
        db.add(problem)
        db.commit()
        db.refresh(problem)

        # 2. Xử lý lưu mảng các bước giải an toàn
        raw_steps = result.get("steps_latex")
        if not raw_steps or (isinstance(raw_steps, list) and len(raw_steps) > 0 and raw_steps[0] == ""):
            raw_steps = result.get("steps", [])

        db_steps_str = json.dumps(raw_steps, ensure_ascii=False) if isinstance(raw_steps, list) else str(raw_steps)

        # 3. Lưu Lời giải
        solution = Solution(
            problem_id=problem.id,
            result=result.get("result", ""),
            steps=db_steps_str,  # Chuỗi JSON an toàn
            latex=result.get("latex", ""),
            model=result.get("solver", result.get("method", "unknown")),
            problem_type=result.get("problem_type", "unknown"),
            graph_image=result.get("graph_image")
        )
        db.add(solution)
        db.commit()
        db.refresh(solution)

        # 4. Lưu Lịch sử
        history = History(
            user_id=user_id,
            problem_id=problem.id,
            solution_id=solution.id
        )
        db.add(history)
        db.commit()
        db.refresh(history)

        return {
            "problem_id": problem.id,
            "solution_id": solution.id,
            "history_id": history.id
        }

    except Exception as e:
        db.rollback()
        logger.error(f"Lỗi khi lưu Database: {str(e)}")
        raise e


@router.post("/solve")
async def solve_text(
        req: SolveRequest,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    try:
        content = req.content
        grade_id = req.grade_id
        chapter_id = req.chapter_id
        lesson_id = req.lesson_id

        result = solve_math(
            content=content,
            grade_id=grade_id,
            chapter_id=chapter_id,
            lesson_id=lesson_id
        )

        saved = save_solution_to_db(
            db=db,
            user_id=current_user.id,
            grade_id=grade_id,
            chapter_id=chapter_id,
            lesson_id=lesson_id,
            content=content,
            result=result,
            input_type="text",
        )

        image_base64 = result.get("image", None)

        return {
            "success": True,
            "type": result.get("problem_type", "unknown"),
            "grade_id": grade_id,
            "chapter_id": chapter_id,
            "lesson_id": lesson_id,
            "problem_id": saved["problem_id"],
            "solution_id": saved["solution_id"],
            "input": content,
            "solution": result,
            "graph_image": image_base64
        }

    except Exception as e:
        logger.error(f"API /solve lỗi: {str(e)}")
        raise HTTPException(status_code=500, detail="Đã xảy ra lỗi hệ thống khi giải bài tập.")


@router.post("/solve-image")
async def solve_image(
        file: UploadFile = File(...),
        grade_id: int = Form(...),
        chapter_id: int = Form(...),
        lesson_id: int = Form(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    try:
        # Tải ảnh và lưu tạm vào thư mục uploads
        os.makedirs("uploads", exist_ok=True)
        filename = f"{uuid.uuid4()}.png"
        file_path = f"uploads/{filename}"

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        latex_content = ocr_service.extract_latex(file_path)
        logger.info(f"Kết quả OCR đọc được: {latex_content}")

        latex_content = latex_content.strip()

        if not latex_content:
            raise HTTPException(status_code=400, detail="Không thể nhận diện được công thức toán trong ảnh.")

        # Tiến hành giải toán sau khi có chuỗi công thức sạch
        result = solve_math(
            content=latex_content,
            grade_id=grade_id,
            chapter_id=chapter_id,
            lesson_id=lesson_id
        )

        # Lưu thông tin bài toán ảnh vào database
        saved = save_solution_to_db(
            db=db,
            user_id=current_user.id,
            content=latex_content,
            result=result,
            input_type="image",
            image_url=f"/uploads/{filename}",
            grade_id=grade_id,
            chapter_id=chapter_id,
            lesson_id=lesson_id
        )

        image_base64 = result.get("image", None)

        return {
            "success": True,
            "type": result.get("problem_type", "unknown"),
            "grade_id": grade_id,
            "chapter_id": chapter_id,
            "lesson_id": lesson_id,
            "problem_id": saved["problem_id"],
            "solution_id": saved["solution_id"],
            "image_url": f"/uploads/{filename}",
            "input": latex_content,
            "solution": result,
            "graph_image": image_base64
        }

    except Exception as e:
        logger.error(f"API /solve-image lỗi: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))