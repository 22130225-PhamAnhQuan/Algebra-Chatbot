# app/services/graph_service.py

from sqlalchemy.orm import Session

from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History

from app.services.solver.graph_solver import solve_graph
from app.schemas.graph import GraphRequest, GraphResponse
from app.models.user import User


class GraphSolverService:

    @staticmethod
    def solve(req: GraphRequest, db: Session, user: User) -> GraphResponse:

        # =========================
        # 1. SOLVE GRAPH (AI / logic)
        # =========================
        result = solve_graph(req.content)

        # =========================
        # 2. SAVE PROBLEM
        # =========================
        problem = Problem(
            user_id=user.id,
            content=req.content,
            input_type='text'
        )
        db.add(problem)
        db.commit()
        db.refresh(problem)

        # =========================
        # 3. SAVE SOLUTION
        # =========================
        solution = Solution(
            problem_id=problem.id,
            result=result.get("result", ""),
            steps="\n".join(result.get("steps", [])),
            latex="",
            model=result.get("solver", "graph_solver")
        )
        db.add(solution)
        db.commit()
        db.refresh(solution)

        # =========================
        # 4. SAVE HISTORY
        # =========================
        history = History(
            user_id=user.id,
            problem_id=problem.id,
            solution_id=solution.id
        )
        db.add(history)
        db.commit()
        db.refresh(history)

        # =========================
        # 5. RESPONSE
        # =========================
        return GraphResponse(
            success=True,
            result=result.get("result", ""),
            steps=result.get("steps", []),
            image=result.get("image"),
            degree=result.get("degree"),
            solver=result.get("solver"),
            features=result.get("features", {})
        )