from sympy import Eq, solve, latex, expand, Mul
from app.services.solver.parser import parse_equation


class LinearSolver:
    def solve(self, content: str):
        TEX_VO_NGHIEM = "\\Leftrightarrow \\text{Phương trình vô nghiệm}"

        try:
            main_var, lhs, rhs, var_name = parse_equation(content)

            steps_latex = []
            steps_latex.append(f"{latex(Eq(lhs, rhs))}")

            expr = lhs - rhs

            # 1. KIỂM TRA PHƯƠNG TRÌNH TÍCH
            factored = expr.factor()
            if isinstance(factored, Mul):
                steps_latex.append(f"\\Leftrightarrow {latex(Eq(factored, 0))}")
                args = [arg for arg in factored.args if arg.has(main_var)]

                if args:
                    bracket_content = r" \\ ".join([f"{latex(Eq(arg, 0))}" for arg in args])
                    steps_latex.append(
                        fr"\Leftrightarrow \left[\begin{{aligned}} {bracket_content} \end{{aligned}}\right.")

                    sols = solve(factored, main_var)
                    sols_latex = "; ".join([latex(s) for s in sols])
                    steps_latex.append(f"\\Leftrightarrow S = \\{{{sols_latex}\\}}")

                    return {"result": f"S = {{{sols_latex}}}", "latex": f"S = \\{{{sols_latex}\\}}",
                            "steps_latex": steps_latex, "type": "linear"}

            # 2. PHƯƠNG TRÌNH BẬC NHẤT THÔNG THƯỜNG
            lhs_expanded = expand(lhs)
            rhs_expanded = expand(rhs)
            if lhs_expanded != lhs or rhs_expanded != rhs:
                steps_latex.append(f"\\Leftrightarrow {latex(Eq(lhs_expanded, rhs_expanded))}")

            sols = solve(Eq(lhs_expanded, rhs_expanded), main_var)

            if not sols:
                steps_latex.append(TEX_VO_NGHIEM)
                return {"result": "Vô nghiệm", "latex": r"\emptyset", "steps_latex": steps_latex, "type": "linear"}

            sols_latex = "; ".join([latex(s) for s in sols])
            steps_latex.append(f"\\Leftrightarrow {var_name} = {sols_latex}")

            return {
                "result": f"{var_name} = {sols_latex}",
                "latex": f"{var_name} = {sols_latex}",
                "steps_latex": steps_latex,
                "type": "linear"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": r"\text{Cú pháp không hợp lệ}",
                "steps_latex": [f"\\text{{Lỗi xử lý: {str(e)}}}"]
            }