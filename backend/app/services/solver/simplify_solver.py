from sympy import *


class SimplifySolver:

    def solve(self, content: str):

        steps = []

        expr = sympify(content)

        steps.append(str(expr))

        expanded = expand(expr)

        if expanded != expr:
            steps.append(f"= {expanded}")

        simplified = simplify(expanded)

        steps.append(f"= {simplified}")

        return {
            "result": str(simplified),
            "steps": steps
        }