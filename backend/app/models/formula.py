from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.database import Base

class Formula(Base):
    __tablename__ = "formulas"

    id = Column(Integer, primary_key=True, index=True)
    grade = Column(Integer, nullable=False)          # Lớp 6, 7, 8, 9
    title = Column(String(255), nullable=False)     # Tên bài học
    formula = Column(Text, nullable=False)           # Công thức toán học
    explanation = Column(Text)                       # Giải thích lý thuyết
    example = Column(Text)                           # Ví dụ minh họa
    category = Column(String(100), default="Đại số")
    created_at = Column(DateTime(timezone=True), server_default=func.now())