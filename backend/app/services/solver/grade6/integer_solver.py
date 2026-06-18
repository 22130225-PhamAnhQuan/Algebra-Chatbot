from sympy import sympify, latex


class IntegerSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            clean_content = content.replace(":", "/").replace("÷", "/").replace("×", "*")

            expr = sympify(clean_content, evaluate=False)
            steps_latex.append(f"\\text{{Thực hiện phép tính: }} {latex(expr)}")

            current = expr
            max_iterations = 5
            iterations = 0

            while iterations < max_iterations:
                iterations += 1
                next_expr = current.doit()
                if next_expr != current:
                    steps_latex.append(f"= {latex(next_expr)}")
                    current = next_expr
                    continue
                break

            return {
                "result": str(current),
                "latex": latex(current),
                "steps_latex": steps_latex,
                "type": "integer_math"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi cú pháp}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}