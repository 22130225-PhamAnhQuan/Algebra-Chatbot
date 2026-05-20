from sympy import *

from app.services.solver.parser import parse_equation


class LinearSolver:

    def solve(self, content: str):

        steps = []

        x, lhs, rhs, var = parse_equation(content)

        steps.append(f"{lhs} = {rhs}")

        lhs_expand = expand(lhs)

        if lhs_expand != lhs:
            steps.append(f"{lhs_expand} = {rhs}")

        expr = expand(lhs_expand - rhs)

        steps.append(f"{expr} = 0")

        poly = expr.as_poly(x)

        if poly.degree() != 1:
            raise Exception("Không phải PT bậc nhất")

        a, b = poly.all_coeffs()

        steps.append(f"{a}{var} + ({b}) = 0")

        moved = -b

        steps.append(f"{a}{var} = {moved}")

        result = simplify(moved / a)

        steps.append(f"{var} = {moved}/{a}")

        steps.append(f"{var} = {result}")

        return {
            "result": f"{var} = {result}",
            "steps": steps
        }