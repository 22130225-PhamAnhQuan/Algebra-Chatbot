from pydantic import BaseModel

class CreateConversationRequest(BaseModel):
    problem_id: int

class SendMessageRequest(BaseModel):
    conversation_id: int
    message: str

class MessageResponse(BaseModel):
    id: int
    conversation_id: int
    role: str
    content: str

    class Config:
        from_attributes = True