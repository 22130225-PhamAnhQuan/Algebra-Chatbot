from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.schemas.formula import FormulaResponse
from app.db.database import get_db
from app.services.formula_service import get_by_grade, search_formula, get_formula_by_id

router = APIRouter(
    prefix="/formulas",
    tags=["Formulas"]
)

@router.get("/grade/{grade}", response_model=List[FormulaResponse])
def read_by_grade(grade: int, db: Session = Depends(get_db)):
    return get_by_grade(db, grade=grade)

@router.get("/search", response_model=List[FormulaResponse])
def search(keyword: str, db: Session = Depends(get_db)):
    # Gọi hàm search từ tầng Service
    return search_formula(db, keyword=keyword)

@router.get("/{formula_id}", response_model=FormulaResponse)
def get_formula_detail(formula_id: int, db: Session = Depends(get_db)):
    formula = get_formula_by_id(db, formula_id=formula_id)
    if not formula:
        raise HTTPException(status_code=404, detail="Không tìm thấy công thức này")
    return formula