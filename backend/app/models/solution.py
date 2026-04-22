from sqlalchemy import Column, Integer, Text, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

# app/models/solution.py
class Solution(Base):
    __tablename__ = "solutions"
    id = Column(Integer, primary_key=True, index=True)
    problem_id = Column(Integer, ForeignKey("problems.id", on_delete="CASCADE"))
    result = Column(Text)
    steps = Column(Text)  # Chúng ta sẽ lưu dạng string cách nhau bởi dấu |
    latex = Column(Text)
    model = Column(String(100))
    created_at = Column(DateTime, server_default=func.now())