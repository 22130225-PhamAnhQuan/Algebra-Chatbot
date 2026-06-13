from sympy import *
from app.services.solver.parser import parse_equation
from sympy import latex


class QuadraticSolver:

    def solve(self, content: str):
        steps = []
        steps_latex = []  # Tạo thêm mảng này để gửi mã toán học sạch về Flutter

        try:
            # 1. Tách vế và chuyển vế đưa về dạng tổng quát = 0
            x, lhs, rhs, var = parse_equation(content)
            expr = expand(lhs - rhs)

            # Đề bài ban đầu
            steps.append("")
            steps_latex.append(latex(Eq(lhs, rhs)))

            # Bước tương đương đưa về dạng ax^2 + bx + c = 0
            steps.append("")
            steps_latex.append(f"\\Leftrightarrow {latex(Eq(expr, 0))}")

            # 2. Bóc tách hệ số an toàn (Chống sập khi khuyết hạng tử)
            poly = Poly(expr, x)
            if poly.degree() != 2:
                return {"result": "Lỗi", "steps_latex": [r"\text{Không phải phương trình bậc 2}"]}

            a = poly.coeff_monomial(x ** 2)
            b = poly.coeff_monomial(x)
            c = poly.coeff_monomial(1)

            # 3. Tính và biện luận biệt thức Delta
            delta = simplify(b ** 2 - 4 * a * c)

            steps.append("")
            steps_latex.append(f"\\text{{Xác định hệ số: }} a = {a}; b = {b}; c = {c}")

            steps.append("")
            steps_latex.append(f"\\Delta = b^2 - 4ac = ({b})^2 - 4 \\cdot ({a}) \\cdot ({c}) = {delta}")

            # 4. Tìm nghiệm thực tế bằng SymPy
            solutions = solve(Eq(expr, 0), x)

            if delta < 0:
                steps.append("")
                steps_latex.append(r"\text{Vì } \Delta < 0 \text{ nên phương trình vô nghiệm.}")
                return {
                    "result": "Vô nghiệm",
                    "latex": r"\emptyset",
                    "steps": steps,
                    "steps_latex": steps_latex
                }

            elif delta == 0:
                x0 = solutions[0]
                steps.append("")
                steps_latex.append(r"\text{Vì } \Delta = 0 \text{ nên phương trình có nghiệm kép:}")
                steps.append("")
                steps_latex.append(f"x_1 = x_2 = \\frac{{-{b}}}{{2 \\cdot {a}}} = {latex(x0)}")

                result_text = f"x = {x0}"
                return {
                    "result": result_text,
                    "latex": f"x_1 = x_2 = {latex(x0)}",
                    "steps": steps,
                    "steps_latex": steps_latex
                }

            else:
                # Sắp xếp nghiệm tăng dần
                solutions = sorted(solutions)
                x1 = solutions[0]
                x2 = solutions[1]

                steps.append("")
                steps_latex.append(r"\text{Vì } \Delta > 0 \text{ nên phương trình có hai nghiệm phân biệt:}")

                # Biến đổi hiển thị phân số theo đúng SGK lớp 9
                steps.append("")
                steps_latex.append(f"x_1 = \\frac{{-({b}) - \\sqrt{{{delta}}}}}{{2 \\cdot {a}}} = {latex(x1)}")
                steps.append("")
                steps_latex.append(f"x_2 = \\frac{{-({b}) + \\sqrt{{{delta}}}}}{{2 \\cdot {a}}} = {latex(x2)}")

                result_text = f"S = {{{latex(x1)}; {latex(x2)}}}"
                return {
                    "result": result_text,
                    "latex": result_text,
                    "steps": steps,
                    "steps_latex": steps_latex
                }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": r"\text{Lỗi cú pháp}",
                "steps": [""],
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }