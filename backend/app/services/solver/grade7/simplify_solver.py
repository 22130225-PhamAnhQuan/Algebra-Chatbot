from sympy import *

from sympy import latex


class SimplifySolver:

    def solve(self, content: str):

        steps = []
        steps_latex = []

        expr = sympify(content)

        steps.append("Ta có:")
        steps.append(str(expr))

        steps_latex.append(
            latex(expr)
        )

        expanded = expand(expr)

        if expanded != expr:

            steps.append(
                f"= {expanded}"
            )

            steps_latex.append(
                latex(expanded)
            )

        simplified = simplify(expanded)

        if simplified != expanded:

            steps.append(
                f"= {simplified}"
            )

            steps_latex.append(
                latex(simplified)
            )

        steps.append(
            f"Vậy kết quả là: {simplified}"
        )

        return {
            "result": str(simplified),
            "latex": latex(simplified),
            "steps": steps,
            "steps_latex": steps_latex
        }