from pydantic import BaseModel
from typing import List, Optional

# Dữ liệu trả về từ AI & SymPy cho lời giải
class SolutionDetail(BaseModel):
    result: str
    steps: List[str]
    latex: str
    graph_image: Optional[str] = None # Chuỗi Base64 nếu có đồ thị

# Dữ liệu phản hồi chính sau khi giải xong
class SolveResponse(BaseModel):
    status: str
    input_detected: str
    input_type: str
    data: SolutionDetail

    class Config:
        from_attributes = True