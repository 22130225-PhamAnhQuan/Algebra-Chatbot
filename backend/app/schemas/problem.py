from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ProblemBase(BaseModel):
    content: str
    input_type: str
    image_url: Optional[str] = None

class ProblemCreate(ProblemBase):
    user_id: int

class ProblemResponse(ProblemBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True