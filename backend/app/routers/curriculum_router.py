import re
from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException

from sqlalchemy.orm import Session

from app.db.database import get_db

from app.schemas.curriculum import (
    GradeResponse,
    ChapterResponse,
    LessonResponse,
    LessonDetailResponse
)

from app.services.curriculum_service import (
    get_all_grades,
    get_chapters_by_grade,
    get_lessons_by_chapter,
    get_lesson_by_id
)

def clean_math_text(text: str) -> str:
    if not text:
        return ""
    replacements = [
        (r'\\cdot\b', ' · '),
        (r'\bcdot\b', ' · '),
        (r'\\vdots\b', ' ⋮ '),
        (r'\bvdots\b', ' ⋮ '),
        (r'\\in\b', ' ∈ '),
        (r'\\rightarrow\b', ' → '),
        (r'\\left\(', '('),
        (r'\\right\)', ')'),
        (r'\\left\[', '['),
        (r'\\right\]', ']'),
        (r'\\left\{', '{'),
        (r'\\right\}', '}'),
        (r'\\leftarrow\b', ' ← '),
        (r'\\leftrightarrow\b', ' ↔ '),
        (r'\\geq\b', ' ≥ '),
        (r'\\leq\b', ' ≤ '),
        (r'\\neq\b', ' ≠ '),
        (r'\\approx\b', ' ≈ '),
        (r'\\infty\b', ' ∞ '),
        (r'\\subset\b', ' ⊂ '),
        (r'\\supset\b', ' ⊃ '),
        (r'\\cup\b', ' ∪ '),
        (r'\\cap\b', ' ∩ '),
        (r'\\emptyset\b', ' ∅ '),
        (r'\\pi\b', ' π '),
        (r'\\alpha\b', ' α '),
        (r'\\beta\b', ' β '),
        (r'\\times\b', ' × '),
        (r'\btimes\b', ' × '),
        (r'\\div\b', ' ÷ '),
        (r'\\pm\b', ' ± '),
    ]
    
    for pat, rep in replacements:
        text = re.sub(pat, rep, text)
        
    text = re.sub(r'\^\{([^}]+)\}', r'^(\1)', text)
    text = re.sub(r'\\text\{([^}]+)\}', r'\1', text)
    text = text.replace('\\{', '{').replace('\\}', '}')
    return text

router = APIRouter(
    prefix="/curriculum",
    tags=["Curriculum"]
)


@router.get(
    "/grades",
    response_model=list[GradeResponse]
)
def get_grades(
    db: Session = Depends(get_db)
):
    return get_all_grades(db)


@router.get(
    "/grades/{grade_id}/chapters",
    response_model=list[ChapterResponse]
)
def get_chapters(
    grade_id: int,
    db: Session = Depends(get_db)
):
    return get_chapters_by_grade(
        db,
        grade_id
    )


@router.get(
    "/chapters/{chapter_id}/lessons",
    response_model=list[LessonResponse]
)
def get_lessons(
    chapter_id: int,
    db: Session = Depends(get_db)
):
    return get_lessons_by_chapter(
        db,
        chapter_id
    )


@router.get(
    "/lessons/{lesson_id}",
    response_model=LessonDetailResponse
)
def get_lesson_detail(
    lesson_id: int,
    db: Session = Depends(get_db)
):

    lesson = get_lesson_by_id(
        db,
        lesson_id
    )

    if lesson is None:
        raise HTTPException(
            status_code=404,
            detail="Lesson not found"
        )

    theory_content = lesson.theory or ""
    if lesson.formula:
        theory_content += f"\n\n[Công thức cần nhớ]\n{lesson.formula}"

    cleaned_theory = clean_math_text(theory_content)
    cleaned_formula = clean_math_text(lesson.formula)
    cleaned_example = clean_math_text(lesson.example)

    return {
        "id": lesson.id,
        "lesson_number": lesson.lesson_number,
        "title": lesson.title,
        "theory": cleaned_theory,
        "formula": cleaned_formula,
        "example": cleaned_example
    }

