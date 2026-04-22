from pydantic import BaseModel

class CreateConversationRequest(BaseModel):
    user_id: int

class SendMessageRequest(BaseModel):
    conversation_id: int
    content: str
