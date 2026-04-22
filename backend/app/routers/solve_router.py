from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.schemas.solve import SolveRequest
from app.services.solve_service import SolverService

router = APIRouter(prefix="/solve", tags=["Solve"])


@router.post("/solve-math")
def solve_math(
    content: str,
    input_type: str = "text",
    image_url: str = None,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        result = SolverService.solve_and_record(
            db,
            user_id=current_user.id,
            content=content,
            input_type=input_type,
            image_url=image_url
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống AI: {str(e)}")
