from sympy import sympify, expand, latex
from app.services.solver.parser import parse_equation


class IdentitySolver:
    def solve(self, content: str):
        TEX_KHAI_TRIEN = "\\text{Khai triển hằng đẳng thức: }"
        TEX_KET_QUA = "\\text{- Áp dụng hằng đẳng thức, ta có:}"

        try:
            # 1. Parsing bằng parser chuẩn của hệ thống
            _, lhs, rhs, _ = parse_equation(content)
            expr = lhs - rhs  # Coi biểu thức là vế trái trừ vế phải

            steps_latex = []
            steps_latex.append(f"{TEX_KHAI_TRIEN} {latex(expr)}")

            # 2. Khai triển
            expanded = expand(expr)

            # 3. Biện luận kết quả
            if expanded != expr:
                steps_latex.append(f"{TEX_KET_QUA}")
                steps_latex.append(f"= {latex(expanded)}")
            else:
                steps_latex.append("\\text{Biểu thức đã ở dạng tối giản hoặc không có hằng đẳng thức.}")

            return {
                "result": str(expanded),
                "latex": latex(expanded),
                "steps_latex": steps_latex,
                "type": "identity"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }