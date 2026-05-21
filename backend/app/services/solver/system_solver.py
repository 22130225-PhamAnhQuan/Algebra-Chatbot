from sympy import *


class SystemSolver:

    def solve(self, content: str):

        steps = []

        x, y = symbols("x y")

        eqs = content.split(";")

        if len(eqs) != 2:
            raise Exception("Hệ phải có 2 phương trình")

        eq1 = eqs[0]
        eq2 = eqs[1]

        steps.append(eq1)
        steps.append(eq2)

        l1, r1 = eq1.split("=")
        l2, r2 = eq2.split("=")

        expr1 = Eq(sympify(l1), sympify(r1))
        expr2 = Eq(sympify(l2), sympify(r2))

        result = solve((expr1, expr2), (x, y))

        steps.append(f"x = {result[x]}")
        steps.append(f"y = {result[y]}")

        return {
            "result": str(result),
            "steps": steps
        }