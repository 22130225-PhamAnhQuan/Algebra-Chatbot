from sympy import *
from sympy import latex


class LinearSolver:

    def solve(self, content: str):

        steps = []
        steps_latex = []

        try:
            # 1. Khai báo biến x và nạp phương trình từ chuỗi (Ví dụ: "2*x + 1 = x - 3")
            x = symbols('x')

            # Tách chuỗi thành vế trái (lhs) và vế phải (rhs) qua dấu "="
            if "=" in content:
                lhs_str, rhs_str = content.split("=")
                lhs = sympify(lhs_str)
                rhs = sympify(rhs_str)
            else:
                lhs = sympify(content)
                rhs = S.Zero

            # Ghi nhận đề bài ban đầu
            steps.append("")
            steps_latex.append(latex(Eq(lhs, rhs)))

            # Chuyển vế tổng quát về dạng: Vế trái - Vế phải = 0
            expr = lhs - rhs

            # 2. KIỂM TRA PHƯƠNG TRÌNH TÍCH (Dạng bài đặc trưng lớp 8)
            if isinstance(expr, Mul) or (hasattr(expr, 'is_Add') and not expr.is_Add):
                # Thử phân tích nhân tử xem có phải phương trình tích không
                factored = factor(expr)
                if isinstance(factored, Mul):
                    steps.append("")
                    steps_latex.append(f"\\Leftrightarrow {latex(Eq(factored, 0))}")

                    args = factored.args
                    # Liệt kê các phương trình thành phần
                    steps.append("")
                    steps_latex.append(r"\Leftrightarrow \left[\begin{aligned} " + r" \\ ".join(
                        [f"{latex(Eq(arg, 0))}" for arg in args if arg.has(x)]) + r" \end{aligned}\right.")

                    # Tìm tập nghiệm
                    sols = solve(factored, x)
                    sols_text = "; ".join([latex(s) for s in sols])
                    steps.append("")
                    steps_latex.append(f"\\Leftrightarrow S = \\{{{sols_text}\\}}")

                    return {"result": str(sols), "latex": f"S = \\{{{sols_text}\\}}", "steps": steps,
                            "steps_latex": steps_latex}

            # Bước 1: Khai triển phá ngoặc hai vế (nếu có)
            lhs_expanded = expand(lhs)
            rhs_expanded = expand(rhs)
            if lhs_expanded != lhs or rhs_expanded != rhs:
                steps.append("")
                steps_latex.append(f"\\Leftrightarrow {latex(Eq(lhs_expanded, rhs_expanded))}")

            # Bước 2: Chuyển các hạng tử chứa x sang VT, hằng số sang VP
            coeff_x = Poly(lhs_expanded - rhs_expanded, x).coeff_monomial(x)
            const_val = (lhs_expanded - rhs_expanded).subs(x, 0)

            vt_final = coeff_x * x
            vp_final = -const_val

            steps.append("")
            steps_latex.append(f"\\Leftrightarrow {latex(Eq(vt_final, vp_final))}")

            # Bước 3: Tìm nghiệm
            sols = solve(Eq(vt_final, vp_final), x)

            if not sols:
                steps_latex.append(r"\Leftrightarrow \text{Phương trình vô nghiệm}")
                result_latex = r"\emptyset"
                result_text = "Vô nghiệm"
            else:
                # Nếu có nhiều nghiệm (ví dụ giải phương trình bậc 2 vô tình lọt vào)
                if len(sols) > 1:
                    sols_text = "; ".join([f"{sol}" for sol in sols])
                    steps_latex.append(f"\\Leftrightarrow \\text{{Nghiệm: }} x \\in \\{{{sols_text}\\}}")
                    result_latex = f"S = \\{{{sols_text}\\}}"
                    result_text = f"S = {{{sols_text}}}"
                else:
                    sol_val = sols[0]
                    steps_latex.append(f"\\Leftrightarrow x = {sol_val}")
                    result_latex = f"x = {sol_val}"
                    result_text = f"x = {sol_val}"

            return {
                "result": result_text,
                "latex": result_latex,
                "steps_latex": steps_latex
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": r"\text{Phương trình không hợp lệ}",
                "steps": [""],
                "steps_latex": [r"\text{Cú pháp phương trình chưa đúng}"]
            }