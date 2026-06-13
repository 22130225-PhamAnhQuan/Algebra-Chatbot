from typing import Optional

from pydantic import BaseModel


class LessonResponse(BaseModel):
    id: int
    lesson_number: int
    title: str

    class Config:
        from_attributes = True


class ChapterResponse(BaseModel):
    id: int
    chapter_number: int
    title: str

    class Config:
        from_attributes = True


class GradeResponse(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True


class LessonDetailResponse(BaseModel):
    id: int
    lesson_number: int
    title: str
    theory: str | None = None
    formula: str | None = None
    example: str | None = None

    class Config:
        from_attributes = True


class ChapterWithLessonsResponse(BaseModel):
    id: int
    chapter_number: int
    title: str
    lessons: list[LessonResponse]

    class Config:
        from_attributes = True


class CurriculumResponse(BaseModel):
    id: int
    name: str
    chapters: list[ChapterWithLessonsResponse]

    class Config:
        from_attributes = True

class LessonCreate(BaseModel):
    chapter_id: int
    lesson_number: int
    title: str
    theory: Optional[str] = None
    formula: Optional[str] = None
    example: Optional[str] = None

class LessonUpdate(BaseModel):
    lesson_number: Optional[int] = None
    title: Optional[str] = None
    theory: Optional[str] = None
    formula: Optional[str] = None
    example: Optional[str] = None

class DeleteLessonResponse(BaseModel):
    id: int
    lesson_number: int