from pydantic import BaseModel


class GraphRequest(BaseModel):
    content: str

class GraphResponse(BaseModel):
    success: bool
    result: str
    steps: list[str]
    image: str | None
    degree: int | str
    solver: str
    features: dict