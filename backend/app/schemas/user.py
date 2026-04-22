from pydantic import BaseModel, EmailStr


class UpdateProfileRequest(BaseModel):
    name: str
    email: EmailStr

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

class LogOutRequest(BaseModel):
    access_token: str
    token_type: str