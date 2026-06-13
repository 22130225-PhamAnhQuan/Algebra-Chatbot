from fastapi import FastAPI, APIRouter
from app.db.database import engine
from app.db.database import Base
from fastapi.staticfiles import StaticFiles
import os

# ROUTERS IMPORT
from app.routers.auth_router import router as auth_router
from app.routers.problem_router import router as problem_router
from app.routers.chat_router import router as chat_router
from app.routers.user_router import router as user_router
from app.routers.solve_router import router as solve_router
from app.routers.history_router import router as history_router
from app.routers.admin_router import router as admin_router
from app.routers.curriculum_router import router as curriculum_router

app = FastAPI(
    title="Algebra Chatbot API",
    description="Hệ thống Backend hỗ trợ giải toán Đại số THCS chuẩn SGK",
    version="1.0.0"
)

Base.metadata.create_all(bind=engine)

api_v1_router = APIRouter(prefix="/api/v1")

# Đăng ký toàn bộ các router con
api_v1_router.include_router(auth_router)
api_v1_router.include_router(problem_router)
api_v1_router.include_router(chat_router)
api_v1_router.include_router(user_router)
api_v1_router.include_router(solve_router)
api_v1_router.include_router(history_router)
api_v1_router.include_router(admin_router)
api_v1_router.include_router(curriculum_router)

app.include_router(api_v1_router)

@app.get("/")
def root():
    return {"message": "Algebra Chatbot API is running 🚀"}

if not os.path.exists("static/uploads"):
    os.makedirs("static/uploads")

app.mount("/static", StaticFiles(directory="static"), name="static")