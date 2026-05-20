from sympy import *

from app.services.solver.parser import parse_equation


class QuadraticSolver:

    def solve(self, content: str):

        steps = []

        x, lhs, rhs, var = parse_equation(content)

        expr = expand(lhs - rhs)

        steps.append(f"{expr} = 0")

        poly = expr.as_poly(x)

        if poly.degree() != 2:
            raise Exception("Không phải PT bậc 2")

        a, b, c = poly.all_coeffs()

        steps.append(f"a = {a}")
        steps.append(f"b = {b}")
        steps.append(f"c = {c}")

        delta = simplify(b**2 - 4*a*c)

        steps.append("Δ = b² - 4ac")

        steps.append(
            f"Δ = ({b})² - 4×({a})×({c})"
        )

        steps.append(f"Δ = {delta}")

        solutions = solve(Eq(expr, 0), x)

        if delta < 0:

            steps.append("Δ < 0")

            steps.append("Vô nghiệm")

            return {
                "result": "Vô nghiệm",
                "steps": steps
            }

        if delta == 0:

            x0 = solutions[0]

            steps.append(f"{var} = {-b}/(2×{a})")

            steps.append(f"{var} = {x0}")

            return {
                "result": f"{var} = {x0}",
                "steps": steps
            }

        x1 = solutions[0]
        x2 = solutions[1]

        steps.append(
            f"{var}₁ = {x1}"
        )

        steps.append(
            f"{var}₂ = {x2}"
        )

        return {
            "result": f"{var}₁ = {x1}, {var}₂ = {x2}",
            "steps": steps
        }