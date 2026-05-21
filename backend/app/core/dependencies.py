from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from starlette import status

from app.db.database import get_db
from app.models.user import User

from app.core.config import SECRET_KEY, ALGORITHM

# cái này giúp lấy token từ header
security = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("user_id")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user

def get_current_admin(
    current_user: User = Depends(get_current_user)
) -> User:
    """
    Dependency kiểm tra quyền Admin.
    Kế thừa lại get_current_user để không phải giải mã JWT lần hai.
    """
    if current_user.role != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Quyền truy cập bị từ chối. Chức năng này chỉ dành cho tài khoản Admin!"
        )
    return current_user