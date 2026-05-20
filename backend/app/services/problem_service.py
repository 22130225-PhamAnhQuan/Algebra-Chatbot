from sqlalchemy.orm import Session
from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History
from app.models.ai_log import AILog
from app.services.solver.ai_solver import AISolver
import time


def solve_problem(db: Session, user_id: int, content: str):

    # 1. Lưu problem
    problem = Problem(
        user_id=user_id,
        content=content,
        input_type="text"
    )
    db.add(problem)
    db.commit()
    db.refresh(problem)

    # 2. Gọi AI
    start = time.time()
    ai_result = AISolver(content)
    latency = int((time.time() - start) * 1000)

    # 3. Lưu solution
    solution = Solution(
        problem_id=problem.id,
        result=ai_result["result"],
        steps=ai_result["steps"],
        latex=ai_result["latex"]
    )
    db.add(solution)
    db.commit()
    db.refresh(solution)

    # 4. Lưu history
    history = History(
        user_id=user_id,
        problem_id=problem.id,
        solution_id=solution.id
    )
    db.add(history)

    # 5. Log AI
    ai_log = AILog(
        user_id=user_id,
        problem_id=problem.id,
        input=content,
        output=str(ai_result),
        model="fake-ai",
        latency_ms=latency
    )
    db.add(ai_log)

    db.commit()

    return {
        "problem_id": problem.id,
        "result": solution.result,
        "steps": solution.steps,
        "latex": solution.latex
    }

    ai_result = solve_math_problem(content)
