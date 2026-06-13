from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    ForeignKey
)

from sqlalchemy.orm import relationship

from app.db.database import Base


class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    chapter_id = Column(
        Integer,
        ForeignKey("chapters.id", ondelete="CASCADE"),
        nullable=False
    )

    lesson_number = Column(
        Integer,
        nullable=False
    )

    title = Column(
        String(255),
        nullable=False
    )

    theory = Column(
        Text,
        nullable=True
    )

    formula = Column(
        Text,
        nullable=True
    )

    example = Column(
        Text,
        nullable=True
    )

    chapter = relationship(
        "Chapter",
        back_populates="lessons"
    )
