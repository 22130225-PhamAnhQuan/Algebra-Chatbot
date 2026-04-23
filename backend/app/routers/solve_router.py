from fastapi import APIRouter, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.services.solve_service import SolveService
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/solver", tags=["Solver"])


@router.post("/solver")
async def solve(
        text: str = Form(None),
        image: UploadFile = File(None),
        db: Session = Depends(get_db),
        current_user=Depends(get_current_user)
):
    image_bytes = await image.read() if image else None

    result = await SolveService.handle_math_solving(
        db=db,
        user_id=current_user.id,
        text=text,
        image_bytes=image_bytes
    )

    return {"status": "success", "data": result}