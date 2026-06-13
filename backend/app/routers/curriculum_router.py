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

    return lesson

