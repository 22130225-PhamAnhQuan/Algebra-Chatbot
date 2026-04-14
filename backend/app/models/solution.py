from sqlalchemy import Column, Integer, Text, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Solution(Base):
    __tablename__ = "solutions"

    id = Column(Integer, primary_key=True)
    problem_id = Column(Integer, ForeignKey("problems.id", ondelete="CASCADE"))

    result = Column(Text)
    steps = Column(Text)
    latex = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    problem = relationship("Problem", back_populates="solution")