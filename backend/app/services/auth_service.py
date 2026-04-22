from sqlalchemy.orm import Session
from app.models.user import User
from app.core.security import hash_password, verify_password, create_access_token


def register_user(db: Session, email: str, name: str, password: str):
    existing = db.query(User).filter(User.email == email).first()

    if existing:
        raise Exception("Email already exists")

    user = User(
        email=email,
        name=name,
        password=hash_password(password)
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


def login_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        raise Exception("User not found")

    if not verify_password(password, user.password):
        raise Exception("Wrong password")

    token = create_access_token({
        "user_id": user.id
    })

    return {
        "access_token": token,
        "token_type": "bearer"
    }