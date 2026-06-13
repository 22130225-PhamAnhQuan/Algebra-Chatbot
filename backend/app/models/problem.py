from sqlalchemy import Column, Integer, Text, ForeignKey, DateTime, String
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Problem(Base):
    __tablename__ = "problems"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    input_type = Column(String(20), default="text")
    image_url = Column(String(500), nullable=True)
    created_at = Column(DateTime, server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="problems")
    solutions = relationship("Solution", back_populates="problem", cascade="all, delete-orphan")
    conversations = relationship("Conversation", back_populates="problem")
    grade_id = Column(
        Integer,
        ForeignKey("grades.id"),
        nullable=True
    )

    chapter_id = Column(
        Integer,
        ForeignKey("chapters.id"),
        nullable=True
    )

    lesson_id = Column(
        Integer,
        ForeignKey("lessons.id"),
        nullable=True
    )
    grade = relationship("Grade")
    chapter = relationship("Chapter")
    lesson = relationship("Lesson")