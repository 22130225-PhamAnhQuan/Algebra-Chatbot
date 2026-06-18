from sympy import symbols, Eq, solve, latex


class DirectInverseSolver:
    def solve_direct(self, a, b, c):
        try:
            x = symbols("x")
            eq = Eq(a / b, c / x)
            ans = solve(eq, x)[0]

            return {
                "result": str(ans),
                "latex": f"x = {latex(ans)}",
                "steps_latex": [
                    "\\text{Vì các đại lượng tỉ lệ thuận, ta có tỉ lệ thức:}",
                    f"\\frac{{{a}}}{{{b}}} = \\frac{{{c}}}{{x}} \\Rightarrow x = {latex(ans)}"
                ],
                "type": "direct_proportion"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}

    def solve_inverse(self, a, b, c):
        try:
            x = symbols("x")
            eq = Eq(a * b, c * x)
            ans = solve(eq, x)[0]

            return {
                "result": str(ans),
                "latex": f"x = {latex(ans)}",
                "steps_latex": [
                    "\\text{Vì các đại lượng tỉ lệ nghịch, ta có:}",
                    f"{a} \\cdot {b} = {c} \\cdot x \\Rightarrow x = {latex(ans)}"
                ],
                "type": "inverse_proportion"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}