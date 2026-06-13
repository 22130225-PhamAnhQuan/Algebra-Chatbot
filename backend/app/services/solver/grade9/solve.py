from app.services.solver.grade9.quadratic_solver import QuadraticSolver
from app.services.solver.grade9.system_solver import SystemSolver
from app.services.solver.grade9.inequality_solver import InequalitySolver
from app.services.solver.graph.graph_solver import GraphSolver
from app.services.solver.grade9.detect import detect_grade9_type

class Grade9Solver:
    def __init__(self):
        self.mapping = {
            "quadratic": QuadraticSolver(),
            "system": SystemSolver(),
            "inequality": InequalitySolver(),
            "graph": GraphSolver(),
        }

    def solve(self, content: str, problem_type: str = None):
        if not problem_type:
            problem_type = detect_grade9_type(content)

        if problem_type not in self.mapping:
            return self.mapping["quadratic"].solve(content)

        return self.mapping[problem_type].solve(content)