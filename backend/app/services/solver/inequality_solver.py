from sympy import *
from sympy.solvers.inequalities import (
    solve_univariate_inequality
)


class InequalitySolver:

    def solve(self, content: str):

        x = symbols("x")

        steps = []

        if "<=" in content:

            lhs, rhs = content.split("<=")

            expr = parse_expr(lhs) <= parse_expr(rhs)

        elif ">=" in content:

            lhs, rhs = content.split(">=")

            expr = parse_expr(lhs) >= parse_expr(rhs)

        elif "<" in content:

            lhs, rhs = content.split("<")

            expr = parse_expr(lhs) < parse_expr(rhs)

        else:

            lhs, rhs = content.split(">")

            expr = parse_expr(lhs) > parse_expr(rhs)

        steps.append(str(expr))

        result = solve_univariate_inequality(
            expr,
            x
        )

        steps.append(str(result))

        return {
            "result": str(result),
            "steps": steps
        }