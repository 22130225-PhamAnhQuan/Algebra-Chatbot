from sympy import *
from app.services.solver.parser import parse_equation
from sympy import latex


class QuadraticSolver:
    def solve(self, content: str):
        steps_latex = []

        try:
            x, lhs, rhs, var = parse_equation(content)
            expr = simplify(lhs - rhs)

            steps_latex.append(f"{latex(Eq(lhs, rhs))}")
            steps_latex.append(f"\\Leftrightarrow {latex(Eq(expr, 0))}")

            poly = Poly(expr, x)
            if poly.degree() != 2:
                return {"result": "Lỗi", "steps_latex": [r"\text{Không phải phương trình bậc 2}"]}

            # Lấy hệ số theo bậc
            a = poly.coeff_monomial(x ** 2)
            b = poly.coeff_monomial(x)
            c = poly.coeff_monomial(1)

            steps_latex.append(f"\\text{{Xác định hệ số: }} a = {a}; b = {b}; c = {c}")

            # Tính Delta
            delta = simplify(b ** 2 - 4 * a * c)
            steps_latex.append(
                f"\\Delta = b^2 - 4ac = ({latex(b)})^2 - 4 \\cdot ({latex(a)}) \\cdot ({latex(c)}) = {latex(delta)}")

            # Tìm nghiệm
            solutions = solve(Eq(expr, 0), x)

            if delta < 0:
                steps_latex.append(r"\text{Vì } \Delta < 0 \text{ nên phương trình vô nghiệm.}")
                result_text = "Vô nghiệm"
                result_latex = r"\emptyset"
            elif delta == 0:
                x0 = simplify(solutions[0])
                steps_latex.append(r"\text{Vì } \Delta = 0 \text{ nên phương trình có nghiệm kép:}")
                steps_latex.append(f"x_1 = x_2 = \\frac{{-{latex(b)}}}{{2 \\cdot {latex(a)}}} = {latex(x0)}")
                result_text = f"x = {x0}"
                result_latex = f"x = {latex(x0)}"
            else:
                solutions = sorted(solutions, key=lambda s: s.evalf())
                steps_latex.append(r"\text{Vì } \Delta > 0 \text{ nên phương trình có hai nghiệm phân biệt:}")
                steps_latex.append(f"x_1 = {latex(solutions[0])}")
                steps_latex.append(f"x_2 = {latex(solutions[1])}")
                result_text = f"S = {{{latex(solutions[0])}; {latex(solutions[1])}}}"
                result_latex = result_text

            return {
                "result": result_text,
                "latex": result_latex,
                "steps": steps_latex,  # Gửi steps_latex cho cả 2 để đồng bộ
                "steps_latex": steps_latex
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": r"\text{Lỗi cú pháp}",
                "steps": [f"\\text{{Lỗi: {str(e)}}}"],
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }