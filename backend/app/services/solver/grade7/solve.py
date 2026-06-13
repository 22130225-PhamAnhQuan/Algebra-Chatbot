from app.services.solver.grade7.polynomial_solver import PolynomialSimplifySolver
from app.services.solver.grade7.evaluate_solver import EvaluateSolver
from app.services.solver.grade7.directlnverse_solver import DirectInverseSolver
from app.services.solver.grade7.proportion_solver import ProportionSolver
from app.services.solver.grade7.simplify_solver import SimplifySolver
from app.services.solver.graph.graph_solver import GraphSolver
from app.services.solver.grade7.detect import detect_grade7_type

class Grade7Solver:
    def __init__(self):
        self.mapping = {
            "polynomial": PolynomialSimplifySolver(),
            "evaluate": EvaluateSolver(),
            "proportional": ProportionSolver(),
            "direct_inverse": DirectInverseSolver(),
            "graph": GraphSolver(),
            "simplify": SimplifySolver(),
        }

    def solve(self, content: str, problem_type: str = None):
        if not problem_type:
            problem_type = detect_grade7_type(content)

        if problem_type not in self.mapping:
            # Fallback an toàn về SimplifySolver
            return self.mapping["simplify"].solve(content)

        return self.mapping[problem_type].solve(content)