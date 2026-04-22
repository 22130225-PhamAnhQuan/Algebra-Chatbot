from sqlalchemy.orm import Session
from app.models.conversation import Conversation
from app.models.message import Message


def create_conversation(db: Session, user_id: int):
    convo = Conversation(user_id=user_id, title="New Chat")
    db.add(convo)
    db.commit()
    db.refresh(convo)
    return convo


def send_message(db: Session, conversation_id: int, content: str):

    # user message
    msg_user = Message(
        conversation_id=conversation_id,
        sender="USER",
        content=content
    )
    db.add(msg_user)

    # fake bot
    msg_bot = Message(
        conversation_id=conversation_id,
        sender="BOT",
        content="AI trả lời: " + content
    )
    db.add(msg_bot)

    db.commit()

    return {"reply": msg_bot.content}