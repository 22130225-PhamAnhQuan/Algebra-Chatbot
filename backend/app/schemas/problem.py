from pydantic import BaseModel

class SolveProblemRequest(BaseModel):
    user_id: int
    content: str
