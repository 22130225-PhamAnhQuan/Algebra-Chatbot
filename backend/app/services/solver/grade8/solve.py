from app.services.solver.grade8.factor_solver import FactorSolver
from app.services.solver.grade8.identity_solver import IdentitySolver
from app.services.solver.grade8.system_solver import LinearSolver
from app.services.solver.grade8.detect import detect_grade8_type
from app.services.solver.graph.graph_solver import GraphSolver

class Grade8Solver:
    def __init__(self):
        self.mapping = {
            "linear": LinearSolver(),
            "identity": IdentitySolver(),
            "factor": FactorSolver(),
            "graph": GraphSolver(),
        }

    def solve(self, content: str, problem_type: str = None):
        if not problem_type:
            problem_type = detect_grade8_type(content)

        if problem_type not in self.mapping:
            return self.mapping["factor"].solve(content) # Fallback an toàn

        return self.mapping[problem_type].solve(content)