from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.db.database import Base


class Chapter(Base):
    __tablename__ = "chapters"

    id = Column(Integer, primary_key=True, index=True)

    grade_id = Column(
        Integer,
        ForeignKey("grades.id")
    )

    chapter_number = Column(Integer)

    title = Column(String(255))

    grade = relationship(
        "Grade",
        back_populates="chapters"
    )

    lessons = relationship(
        "Lesson",
        back_populates="chapter",
        cascade="all, delete-orphan"
    )