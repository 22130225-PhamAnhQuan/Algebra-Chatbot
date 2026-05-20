from pydantic import BaseModel
from typing import List, Optional


# =========================================================
# DETAIL SOLUTION
# =========================================================

class SolutionDetail(BaseModel):

    result: str

    steps: List[str]

    latex: Optional[str] = None

    graph_image: Optional[str] = None

    model: Optional[str] = None

    method: Optional[str] = None

    problem_type: Optional[str] = None


# =========================================================
# MAIN RESPONSE
# =========================================================

class SolveResponse(BaseModel):

    success: bool

    message: str

    input_detected: str

    input_type: str

    problem_id: Optional[int] = None

    solution_id: Optional[int] = None

    data: SolutionDetail

    class Config:
        from_attributes = True