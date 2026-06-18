from sympy import expand, collect, latex
from app.services.solver.parser import parse_equation


class PolynomialSimplifySolver:
    def solve(self, content: str):
        TEX_BIEU_THUC = "\\text{Biểu thức đa thức cần xử lý: }"
        TEX_KHAI_TRIEN = "\\text{- Khai triển biểu thức:}"
        TEX_THU_GON = "\\text{- Thu gọn và sắp xếp theo lũy thừa giảm dần:}"
        TEX_KET_QUA = "\\Rightarrow \\text{Kết quả cuối cùng: }"

        try:
            main_var, lhs, rhs, var_name = parse_equation(content)

            # Nếu học sinh không nhập dấu '=', rhs sẽ là 0
            expr = lhs - rhs if rhs != 0 else lhs

            steps_latex = []
            steps_latex.append(f"{TEX_BIEU_THUC} {latex(expr)}")

            expanded = expand(expr)
            if expanded != expr:
                steps_latex.append(TEX_KHAI_TRIEN)
                steps_latex.append(f"= {latex(expanded)}")

            # Tự động gộp nhóm và sắp xếp lũy thừa giảm dần
            result = collect(expanded, main_var)

            if result != expanded:
                steps_latex.append(TEX_THU_GON)
                steps_latex.append(f"= {latex(result)}")

            steps_latex.append(f"{TEX_KET_QUA} {latex(result)}")

            return {
                "result": str(result),
                "latex": latex(result),
                "steps_latex": steps_latex,
                "type": "polynomial"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi xử lý: {str(e)}}}"]
            }