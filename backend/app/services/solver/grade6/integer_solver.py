from sympy import sympify


class IntegerSolver:
    def solve(self, content: str):
        steps = []
        clean_content = content.replace(":", "/").replace("÷", "/").replace("×", "*")

        expr = sympify(clean_content, evaluate=False)
        steps.append(f"\\text{{Thực hiện phép tính: }} {content}")

        current = expr
        max_iterations = 5
        iterations = 0

        while iterations < max_iterations:
            iterations += 1

            next_expr = current.doit()
            if next_expr != current:
                steps.append(f"= {next_expr}")
                current = next_expr
                continue
            break

        return {
            "result": f"{current}",
            "latex": f"{current}",
            "steps_latex": steps
        }