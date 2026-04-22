from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.services.history_service import HistoryService
from app.schemas.history import HistoryDetailResponse
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/his", tags=["HIS"])

@router.get("/history", response_model=List[HistoryDetailResponse])
def read_history(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Trả về danh sách bài giải cho Quan
    return HistoryService.get_my_history(db, user_id=current_user.id)