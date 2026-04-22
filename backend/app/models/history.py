from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base

class History(Base):
    __tablename__ = "histories"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", on_delete="CASCADE"))
    problem_id = Column(Integer, ForeignKey("problems.id", on_delete="CASCADE"))
    solution_id = Column(Integer, ForeignKey("solutions.id", on_delete="CASCADE"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Quan hệ để lấy dữ liệu đề và giải trong 1 lần truy vấn
    user = relationship("User")
    problem = relationship("Problem")
    solution = relationship("Solution")