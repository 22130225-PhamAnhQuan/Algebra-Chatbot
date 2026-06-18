from app.services.solver.grade8.factor_solver import FactorSolver
from app.services.solver.grade8.identity_solver import IdentitySolver
from app.services.solver.grade8.rational_solver import RationalEquationSolver
from app.services.solver.grade8.system_solver import SystemSolver
from app.services.solver.graph.graph_solver import GraphSolver
from app.services.solver.linear_solver import LinearSolver
from app.services.solver.grade8.detect import detect_grade8_type

class Grade8Solver:
    def __init__(self):
        self.mapping = {
            "rational": RationalEquationSolver(),
            "system": SystemSolver(),
            "identity": IdentitySolver(),
            "factor": FactorSolver(),
            "graph": GraphSolver(),
            "linear": LinearSolver(),
        }

    def solve(self, content: str, problem_type: str = None):
        if not problem_type:
            problem_type = detect_grade8_type(content)

        if problem_type not in self.mapping:
            fallback_type = "linear" if "=" in content else "factor"
            return self.mapping[fallback_type].solve(content)

        return self.mapping[problem_type].solve(content)