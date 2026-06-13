from app.services.solver.grade6.integer_solver import IntegerSolver
from app.services.solver.grade6.fraction_solver import FractionArithmeticSolver
from app.services.solver.grade6.exponent_solver import ExponentSolver
from app.services.solver.grade6.GCD_solver import GcdSolver
from app.services.solver.grade6.LCM_solver import LcmSolver
from app.services.solver.grade6.ratio_solver import RatioSolver
from app.services.solver.grade6.percentage_solver import PercentageSolver
from app.services.solver.grade6.prime_factor_solver import PrimeFactorSolver
from app.services.solver.grade6.detect import detect_grade6_type


class Grade6Solver:

    def __init__(self):

        self.mapping = {

            "integer": IntegerSolver(),

            "fraction": FractionArithmeticSolver(),

            "exponent": ExponentSolver(),

            "gcd": GcdSolver(),

            "lcm": LcmSolver(),

            "ratio": RatioSolver(),

            "percentage": PercentageSolver(),

            "prime_factor": PrimeFactorSolver(),
        }

    def solve(self, content: str, problem_type: str = None):

        if not problem_type:
            problem_type = detect_grade6_type(content)

        if problem_type not in self.mapping:
            raise Exception(
                f"Unsupported Grade 6 type: {problem_type}"
            )

        return self.mapping[problem_type].solve(content)

