import random
from datetime import datetime, timedelta
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def generate_otp():
    return str(random.randint(100000, 999999))


def hash_otp(otp: str):
    return pwd_context.hash(otp)


def verify_otp(otp: str, otp_hash: str):
    return pwd_context.verify(otp, otp_hash)


def get_expiry():
    return datetime.utcnow() + timedelta(minutes=5)