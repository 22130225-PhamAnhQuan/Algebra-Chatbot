from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.db.database import Base

class History(Base):
    __tablename__ = "histories"

    id = Column(Integer, primary_key=True)

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    problem_id = Column(Integer, ForeignKey("problems.id", ondelete="CASCADE"))
    solution_id = Column(Integer, ForeignKey("solutions.id", ondelete="CASCADE"))

    created_at = Column(DateTime(timezone=True), server_default=func.now())