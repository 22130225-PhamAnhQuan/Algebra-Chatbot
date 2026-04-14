from fastapi import FastAPI
from app.db.database import engine, Base
from app.models import user, problem, solution, message

Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Backend OK"}