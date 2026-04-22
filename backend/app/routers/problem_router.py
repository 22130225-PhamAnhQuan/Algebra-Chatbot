from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.schemas.problem import SolveProblemRequest
from app.services.problem_service import solve_problem

router = APIRouter(prefix="/problem", tags=["Problem"])


@router.post("/solve")
def solve(
    req: SolveProblemRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return solve_problem(db, req.user_id, req.content)
