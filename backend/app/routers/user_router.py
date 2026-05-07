from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.schemas.user import UpdateProfileRequest, ChangePasswordRequest
from app.core.security import verify_password, hash_password
from app.models import User, RefreshToken

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/profile")
def get_profile(user = Depends(get_current_user)):
    return {
        "id": user.id,
        "email": user.email,
        "name": user.name
    }

@router.put("/update")
def update_profile(
    req: UpdateProfileRequest,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    user.name = req.name

    db.commit()
    db.refresh(user)

    return {
        "message": "Updated successfully",
        "user": {
            "id": user.id,
            "name": user.name
        }
    }

@router.put("/change-password")
def change_password(
    req: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    # check mật khẩu cũ
    if not verify_password(req.old_password, user.password):
        raise HTTPException(status_code=400, detail="Old password incorrect")

    # update mật khẩu mới
    user.password = hash_password(req.new_password)

    db.commit()

    return {"message": "Password changed successfully"}


@router.post("/logout")
def logout(
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
):
    try:
        # Tìm và xóa toàn bộ Refresh Token của user này trong DB
        db.query(RefreshToken).filter(RefreshToken.user_id == current_user.id).delete()
        db.commit()

        return {"message": "Đăng xuất thành công. Đã thu hồi phiên đăng nhập."}

    except Exception as e:
        db.rollback()  # Hoàn tác nếu có lỗi DB
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Lỗi hệ thống khi đăng xuất"
        )