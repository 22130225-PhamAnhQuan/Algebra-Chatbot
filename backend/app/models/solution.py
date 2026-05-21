from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Solution(Base):
    __tablename__ = "solutions"

    id = Column(Integer, primary_key=True, index=True)
    problem_id = Column(Integer, ForeignKey("problems.id", ondelete="CASCADE"), nullable=False)
    result = Column(Text)
    steps = Column(Text)
    latex = Column(Text)
    model = Column(String(100))
    problem_type = Column(String(50), default="unknown")
    created_at = Column(DateTime, server_default=func.now())

    # Relationships
    problem = relationship("Problem", back_populates="solutions")