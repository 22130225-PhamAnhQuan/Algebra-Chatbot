from fastapi import FastAPI
from app.db.database import engine
from app.db.database import Base

# IMPORT MODELS (QUAN TRỌNG)
from app import models
from app.routers.history_router import router as history_router

# ROUTERS
from app.routers.auth_router import router as auth_router
from app.routers.problem_router import router as problem_router
from app.routers.chat_router import router as chat_router
from app.routers.user_router import router as user_router
from app.routers.formula_router import router as formula_router
from app.routers.solve_router import router as solve_router

app = FastAPI()

# AUTO CREATE TABLE
Base.metadata.create_all(bind=engine)

# ROUTES
app.include_router(auth_router)
app.include_router(problem_router)
app.include_router(chat_router)
app.include_router(user_router)
app.include_router(formula_router)
app.include_router(solve_router)
app.include_router(history_router)

@app.get("/")
def root():
    return {"message": "Algebra Chatbot API is running 🚀"}