import os
from dotenv import load_dotenv

# Load biến từ file .env
load_dotenv()

#Database
DATABASE_URL = os.getenv("DATABASE_URL")

# JWT Security
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")

# Email
EMAIL_HOST = os.getenv("EMAIL_HOST")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", 587))
EMAIL_USERNAME = os.getenv("EMAIL_USERNAME")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")
EMAIL_FROM = os.getenv("EMAIL_FROM")

# Google & AI
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
OLLAMA_URL = os.getenv("OLLAMA_URL")

# Thời gian hết hạn
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 120))