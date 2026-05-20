from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.schemas.problem import ProblemResponse
from app.services.problem_service import solve_problem

router = APIRouter(prefix="/problem", tags=["Problem"])


@router.post("")
def solve(
    req: ProblemResponse,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return solve_problem(db, req.user_id, req.content)
