from sqlalchemy import Column, Integer, Text, ForeignKey, DateTime, String
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Problem(Base):
    __tablename__ = "problems"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))

    content = Column(Text, nullable=False)
    input_type = Column(String(20), default="text")

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # relationships
    user = relationship("User", back_populates="problems")
    solution = relationship("Solution", back_populates="problem", uselist=False)