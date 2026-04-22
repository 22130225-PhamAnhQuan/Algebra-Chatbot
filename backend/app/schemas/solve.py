from pydantic import BaseModel

class SolveRequest(BaseModel):
    content: str
    user_id: int
