from sympy import sympify, Pow

class ExponentSolver:
    def solve(self, content: str):
        steps = []
        clean_content = content.replace("^", "**")
        expr = sympify(clean_content)

        steps.append(f"\\text{{Tính lũy thừa: }} {content}")

        if isinstance(expr, Pow):
            base = expr.base
            exp = expr.exp
            if str(exp).isdigit() and int(exp) <= 10:
                multiplication = " \\cdot ".join([str(base)] * int(exp))
                steps.append(f"= {multiplication}")

        result = expr.doit()
        steps.append(f"= {result}")

        return {
            "result": f"{result}",
            "latex": f"{result}",
            "steps_latex": steps
        }