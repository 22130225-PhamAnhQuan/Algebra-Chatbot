from fastapi import APIRouter
from app.services.math_service import solve_linear_equation, plot_graph

router = APIRouter(prefix="/math", tags=["Math"])


@router.post("/solve")
def solve_math(data: dict):
    return solve_linear_equation(data["content"])


@router.post("/graph")
def draw_graph(data: dict):
    return plot_graph(data["expression"])