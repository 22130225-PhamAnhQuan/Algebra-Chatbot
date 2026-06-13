from pydantic import BaseModel
from typing import Optional


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


class GradeResponse(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True


class ChapterResponse(BaseModel):
    id: int
    grade_id: int
    name: str

    class Config:
        from_attributes = True


class LessonResponse(BaseModel):
    id: int
    chapter_id: int
    lesson_number: int
    title: str
    theory: Optional[str]
    formula: Optional[str]
    example: Optional[str]

    class Config:
        from_attributes = True