from sympy import expand, simplify, latex
from app.services.solver.parser import parse_equation


class SimplifySolver:
    def solve(self, content: str):
        TEX_TA_CO = "\\text{Ta có: }"
        TEX_KET_QUA = "\\text{Vậy kết quả là: }"

        try:
            main_var, lhs, rhs, var_name = parse_equation(content)
            expr = lhs - rhs if rhs != 0 else lhs

            steps_latex = []
            steps_latex.append(f"{TEX_TA_CO} {latex(expr)}")

            expanded = expand(expr)
            if expanded != expr:
                steps_latex.append(f"= {latex(expanded)}")

            simplified = simplify(expanded)
            if simplified != expanded:
                steps_latex.append(f"= {latex(simplified)}")

            steps_latex.append(f"{TEX_KET_QUA} {latex(simplified)}")

            return {
                "result": str(simplified),
                "latex": latex(simplified),
                "steps_latex": steps_latex,
                "type": "simplify"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }