from sympy import *


class FactorSolver:

    def solve(self, content: str):

        steps = []

        expr = sympify(content)

        steps.append(str(expr))

        factored = factor(expr)

        steps.append(
            f"= {factored}"
        )

        return {
            "result": str(factored),
            "steps": steps
        }