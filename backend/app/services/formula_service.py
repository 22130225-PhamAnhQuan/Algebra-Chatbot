from sqlalchemy.orm import Session
from app.models.formula import Formula

def get_all(db: Session):
    return db.query(Formula).all()

def get_by_grade(db: Session, grade: int):
    return db.query(Formula).filter(Formula.grade == grade).all()

def search_formula(db: Session, keyword: str):
    return db.query(Formula).filter(
        Formula.title.ilike(f"%{keyword}%") |
        Formula.formula.ilike(f"%{keyword}%")
    ).all()

def get_formula_by_id(db: Session, formula_id: int):
    return db.query(Formula).filter(Formula.id == formula_id).first()