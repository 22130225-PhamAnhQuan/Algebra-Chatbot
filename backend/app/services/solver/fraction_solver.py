from sympy import *

from app.services.solver.parser import parse_equation


class FractionSolver:

    def solve(self, content: str):

        steps = []

        x, lhs, rhs, var = parse_equation(content)

        steps.append(f"{lhs} = {rhs}")

        expr = together(lhs - rhs)

        steps.append(f"{expr} = 0")

        numerator_expr = numerator(expr)

        steps.append(f"{numerator_expr} = 0")

        solutions = solve(Eq(numerator_expr, 0), x)

        for s in solutions:
            steps.append(f"{var} = {s}")

        return {
            "result": str(solutions),
            "steps": steps
        }