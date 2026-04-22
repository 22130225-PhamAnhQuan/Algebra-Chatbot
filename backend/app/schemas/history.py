from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class HistoryDetailResponse(BaseModel):
    id: int
    created_at: datetime
    # Thông tin từ bảng problems
    problem_content: str
    input_type: str
    # Thông tin từ bảng solutions
    result: Optional[str]
    steps: Optional[str]
    latex: Optional[str]

    class Config:
        from_attributes = True