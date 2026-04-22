from pydantic import BaseModel
from typing import Optional

class FormulaResponse(BaseModel):
    id: int
    grade: int
    title: str
    formula: str
    explanation: Optional[str] = None
    example: Optional[str] = None
    category: Optional[str] = None

    class Config:
        from_attributes = True