from sqlalchemy.orm import Session, joinedload

from app.models.grade import Grade
from app.models.chapter import Chapter
from app.models.lesson import Lesson


def get_all_grades(db: Session):

    return (
        db.query(Grade)
        .order_by(Grade.id)
        .all()
    )


def get_chapters_by_grade(
    db: Session,
    grade_id: int
):

    return (
        db.query(Chapter)
        .filter(
            Chapter.grade_id == grade_id
        )
        .order_by(
            Chapter.chapter_number
        )
        .all()
    )


def get_lessons_by_chapter(
    db: Session,
    chapter_id: int
):

    return (
        db.query(Lesson)
        .filter(
            Lesson.chapter_id == chapter_id
        )
        .order_by(
            Lesson.lesson_number
        )
        .all()
    )


def get_lesson_by_id(
    db: Session,
    lesson_id: int
):

    return (
        db.query(Lesson)
        .filter(
            Lesson.id == lesson_id
        )
        .first()
    )


def get_curriculum_by_grade(
    db: Session,
    grade_id: int
):

    return (
        db.query(Grade)
        .options(
            joinedload(Grade.chapters)
            .joinedload(Chapter.lessons)
        )
        .filter(
            Grade.id == grade_id
        )
        .first()
    )
