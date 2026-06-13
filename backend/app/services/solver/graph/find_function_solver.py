from sympy import *


class FindFunctionSolver:

    def solve(self, points):

        steps = []

        if len(points) != 2:
            raise Exception(
                "Cần đúng 2 điểm"
            )

        x1, y1 = points[0]
        x2, y2 = points[1]

        a, b = symbols("a b")

        steps.append(
            "Giả sử hàm số có dạng:"
        )

        steps.append(
            "y = ax + b"
        )

        eq1 = Eq(
            a * x1 + b,
            y1
        )

        eq2 = Eq(
            a * x2 + b,
            y2
        )

        steps.append(
            f"{x1}a + b = {y1}"
        )

        steps.append(
            f"{x2}a + b = {y2}"
        )

        solution = solve(
            (eq1, eq2),
            (a, b)
        )

        a_value = simplify(
            solution[a]
        )

        b_value = simplify(
            solution[b]
        )

        steps.append(
            f"a = {a_value}"
        )

        steps.append(
            f"b = {b_value}"
        )

        steps.append(
            f"Vậy hàm số là:"
        )

        steps.append(
            f"y = {a_value}x + ({b_value})"
        )

        return {
            "result":
                f"y = {a_value}x + ({b_value})",
            "steps":
                steps,
            "function": {
                "a": str(a_value),
                "b": str(b_value)
            }
        }
