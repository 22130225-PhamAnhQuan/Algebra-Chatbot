from app.services.solver.grade9.quadratic_solver import QuadraticSolver
from app.services.solver.grade9.system_solver import SystemSolver
from app.services.solver.grade9.inequality_solver import InequalitySolver
from app.services.solver.grade8.rational_solver import RationalEquationSolver
from app.services.solver.graph.graph_solver import GraphSolver
from app.services.solver.grade9.detect import detect_grade9_type

class Grade9Solver:
    def __init__(self):
        self.mapping = {
            "quadratic": QuadraticSolver(),
            "system": SystemSolver(),
            "inequality": InequalitySolver(),
            "graph": GraphSolver(),
            "rational": RationalEquationSolver(),
        }

    def solve(self, content: str, problem_type: str = None):
        if not problem_type:
            problem_type = detect_grade9_type(content)

        if problem_type not in self.mapping:
            fallback = "linear" if "=" in content else "quadratic"
            return self.mapping[fallback].solve(content)

        return self.mapping[problem_type].solve(content)