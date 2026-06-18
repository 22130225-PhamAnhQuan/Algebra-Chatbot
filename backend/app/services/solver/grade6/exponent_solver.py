from sympy import sympify, Pow, latex

class ExponentSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            clean_content = content.replace("^", "**")
            expr = sympify(clean_content)

            steps_latex.append(f"\\text{{Tính giá trị lũy thừa: }} {latex(expr)}")

            if isinstance(expr, Pow):
                base, exp = expr.base, expr.exp
                if str(exp).isdigit() and int(exp) <= 10:
                    multiplication = " \\cdot ".join([latex(base)] * int(exp))
                    steps_latex.append(f"= {multiplication}")

            result = expr.doit()
            steps_latex.append(f"= {latex(result)}")

            return {
                "result": str(result),
                "latex": latex(result),
                "steps_latex": steps_latex,
                "type": "exponent"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}