from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session

import shutil
import uuid
import os

from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User

from app.services.solver.detector import detect_type
from app.services.solve_service import solve_math
from app.services.solver.graph_solver import solve_graph
from app.services.ocr_service import OCRService

from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History

router = APIRouter()
ocr_service = OCRService()


# =========================================================
# SAVE TO DB (COMMON)
# =========================================================
def save_solution_to_db(
    db: Session,
    user_id: int,
    content: str,
    result: dict,
    input_type: str,
    image_url: str = None
):

    try:
        # ================= PROBLEM =================
        problem = Problem(
            user_id=user_id,
            content=content,
            input_type=input_type,
            image_url=image_url
        )

        db.add(problem)
        db.commit()
        db.refresh(problem)

        # ================= SOLUTION =================
        solution = Solution(
            problem_id=problem.id,
            result=result.get("result", ""),
            steps="\n".join(result.get("steps", []))
            if isinstance(result.get("steps"), list)
            else str(result.get("steps", "")),
            latex=result.get("latex", ""),
            model=result.get("method", result.get("solver", "unknown")),
            problem_type=result.get("problem_type", "unknown")
        )

        db.add(solution)
        db.commit()
        db.refresh(solution)

        # ================= HISTORY =================
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
        raise e


# =========================================================
# SOLVE TEXT
# =========================================================
@router.post("/solve")
async def solve_text(
    req: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    try:
        content = req.get("content", "")

        problem_type = detect_type(content)

        # ================= GRAPH =================
        if problem_type == "graph":
            result = solve_graph(content)

        # ================= ALGEBRA =================
        else:
            result = solve_math(content)

        # ================= SAVE DB =================
        saved = save_solution_to_db(
            db=db,
            user_id=current_user.id,
            content=content,
            result=result,
            input_type="text",
        )

        return {
            "success": True,
            "type": problem_type,
            "problem_id": saved["problem_id"],
            "solution_id": saved["solution_id"],
            "input": content,
            "solution": result
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =========================================================
# SOLVE IMAGE (OCR + SOLVE)
# =========================================================
@router.post("/solve-image")
async def solve_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    try:
        # ================= SAVE IMAGE =================
        os.makedirs("uploads", exist_ok=True)

        filename = f"{uuid.uuid4()}.png"
        file_path = f"uploads/{filename}"

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # ================= OCR =================
        latex = ocr_service.extract_latex(file_path)
        latex = latex.strip().replace("\n", " ")

        # ================= DETECT =================
        problem_type = detect_type(latex)

        # ================= SOLVE =================
        if problem_type == "graph":
            result = solve_graph(latex)
        else:
            result = solve_math(latex)

        # ================= SAVE DB =================
        saved = save_solution_to_db(
            db=db,
            user_id=current_user.id,
            content=latex,
            result=result,
            input_type="image",
            image_url=f"/uploads/{filename}"
        )

        return {
            "success": True,
            "type": problem_type,
            "problem_id": saved["problem_id"],
            "solution_id": saved["solution_id"],
            "image_url": f"/uploads/{filename}",
            "latex": latex,
            "solution": result
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))