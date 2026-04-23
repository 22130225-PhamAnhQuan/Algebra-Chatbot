from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base

class AILog(Base):
    __tablename__ = "ai_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    problem_id = Column(Integer, ForeignKey("problems.id", ondelete="SET NULL"), nullable=True)
    input = Column(Text)
    output = Column(Text)
    model = Column(String(100))
    latency_ms = Column(Integer)
    tokens_used = Column(Integer)
    status = Column(String(20))
    created_at = Column(DateTime, server_default=func.now())