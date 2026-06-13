from sqlalchemy.orm import Session

from app.models.grade import Grade
from app.models.chapter import Chapter
from app.models.lesson import Lesson

from app.schemas.admin import (
    LessonCreate,
    LessonUpdate
)

def get_grades(db: Session):
    return db.query(Grade)\
        .order_by(Grade.id)\
        .all()

def get_chapters(
        db: Session,
        grade_id: int
):
    return db.query(Chapter)\
        .filter(
            Chapter.grade_id == grade_id
        )\
        .order_by(Chapter.id)\
        .all()

def get_lessons(
        db: Session,
        chapter_id: int
):
    return db.query(Lesson)\
        .filter(
            Lesson.chapter_id == chapter_id)\
        .order_by(
            Lesson.lesson_number
        )\
        .all()

def create_lesson(
        db: Session,
        lesson_data: LessonCreate
):
    lesson = Lesson(
        chapter_id=lesson_data.chapter_id,
        lesson_number=lesson_data.lesson_number,
        title=lesson_data.title,
        theory=lesson_data.theory,
        formula=lesson_data.formula,
        example=lesson_data.example
    )

    db.add(lesson)
    db.commit()
    db.refresh(lesson)

    return lesson

def update_lesson(
        db: Session,
        lesson_id: int,
        lesson_data: LessonUpdate
):
    lesson = db.query(Lesson)\
        .filter(Lesson.id == lesson_id)\
        .first()

    if not lesson:
        return None

    update_data = lesson_data.dict(
        exclude_unset=True
    )

    for key, value in update_data.items():
        setattr(
            lesson,
            key,
            value
        )

    db.commit()
    db.refresh(lesson)

    return lesson

def delete_lesson(
        db: Session,
        lesson_id: int
):
    lesson = db.query(Lesson)\
        .filter(
            Lesson.id == lesson_id
        )\
        .first()

    if not lesson:
        return False

    db.delete(lesson)
    db.commit()

    return True