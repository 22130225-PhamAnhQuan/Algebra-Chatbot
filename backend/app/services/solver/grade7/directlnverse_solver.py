from sympy import *


class DirectInverseSolver:

    def solve_direct(self, a, b, c):

        x = symbols("x")

        eq = Eq(
            a / b,
            c / x
        )

        return solve(eq, x)[0]

    def solve_inverse(self, a, b, c):

        x = symbols("x")

        eq = Eq(
            a * b,
            c * x
        )

        return solve(eq, x)[0]