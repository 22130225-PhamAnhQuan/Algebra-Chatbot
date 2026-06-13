from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.db.database import get_db
from app.models import User
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, ForgotPasswordRequest, ResetPasswordRequest, CheckOTP
from app.services.auth_service import register_user, login_user
from app.core.security import verify_reset_token, hash_password
from app.models.otp_code import OtpCode
from app.services.otp_service import generate_otp, hash_otp, verify_otp, get_expiry
from app.services.email_service import send_otp_email
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from app.schemas.auth import GoogleAuthRequest
import secrets # Dùng để tạo mật khẩu ngẫu nhiên
from app.core.config import GOOGLE_CLIENT_ID

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    try:
        user = register_user(db, req.email, req.name, req.password)
        return {"message": "Register success", "user_id": user.id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    try:
        return login_user(db, req.email, req.password)
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.post("/google")
def google_auth(req: GoogleAuthRequest, db: Session = Depends(get_db)):
    try:
        # 1. Xác thực token với máy chủ Google
        idinfo = id_token.verify_oauth2_token(
            req.id_token,
            google_requests.Request(),
            GOOGLE_CLIENT_ID
        )

        email = idinfo['email']
        name = idinfo.get('name', 'Học sinh AI')

        # 2. Kiểm tra xem email này đã có trong DB chưa
        user = db.query(User).filter(User.email == email).first()

        # 3. Nếu chưa có Tạo tài khoản mới
        if not user:
            random_password = secrets.token_urlsafe(16)
            user = register_user(db, email, name, random_password)

        # 4. Đăng nhập và tạo JWT Access Token
        from app.core.security import create_access_token
        access_token = create_access_token(data={"sub": user.email})

        return {"access_token": access_token, "token_type": "bearer"}

    except ValueError:
        raise HTTPException(status_code=400, detail="Token Google không hợp lệ")

@router.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()

    if not user:
        raise HTTPException(status_code=404, detail="Email không tồn tại")

    recent = db.query(OtpCode).filter(
        OtpCode.email == req.email,
        OtpCode.created_at > datetime.utcnow() - timedelta(minutes=5)
    ).count()

    if recent >= 3:
        raise HTTPException(status_code=429, detail="Gửi OTP quá nhiều")

    db.query(OtpCode).filter(
        OtpCode.email == req.email,
        OtpCode.is_used == False
    ).delete()

    otp = generate_otp()

    otp_record = OtpCode(
        user_id=user.id,
        email=req.email,
        code_hash=hash_otp(otp),
        expires_at=get_expiry()
    )

    db.add(otp_record)
    db.flush()

    try:
        send_otp_email(req.email, otp)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Không thể gửi email. Thử lại sau.")
    db.commit()

    return {"message": "OTP đã gửi về email"}

@router.post("/verify-otp")
def verify_otp_endpoint(req: CheckOTP, db: Session = Depends(get_db)):
    record = db.query(OtpCode).filter(
        OtpCode.email == req.email,
        OtpCode.is_used == False
    ).order_by(OtpCode.created_at.desc()).first()

    if not record:
        raise HTTPException(status_code=400, detail="Không tìm thấy mã OTP cho email này")

    if record.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Mã OTP đã hết hạn (quá 5 phút)")

    if not verify_otp(req.otp, record.code_hash):
        raise HTTPException(status_code=400, detail="Mã OTP không chính xác")

    record.is_used = True
    db.commit()

    return {"message": "OTP hợp lệ, cho phép đổi mật khẩu"}

@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):

    record = db.query(OtpCode).filter(
        OtpCode.email == req.email,
        OtpCode.is_used == True,
    ).order_by(OtpCode.created_at.desc()).first()

    if not record:
        raise HTTPException(status_code=400, detail="Không tìm thấy OTP")

    if record.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP đã hết hạn")

    if not verify_otp(req.otp, record.code_hash):
        raise HTTPException(status_code=400, detail="OTP không đúng")

    user = db.query(User).filter(User.email == req.email).first()

    if not user:
        raise HTTPException(status_code=404, detail="User không tồn tại")

    user.password = hash_password(req.new_password)

    db.delete(record)
    db.commit()

    return {"message": "Đổi mật khẩu thành công"}