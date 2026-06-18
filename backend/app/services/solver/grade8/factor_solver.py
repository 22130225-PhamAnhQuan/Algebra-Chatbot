from sympy import sympify, factor, latex
from app.services.solver.parser import parse_equation


class FactorSolver:
    def solve(self, content: str):
        TEX_PHAN_TICH = "\\text{Phân tích đa thức thành nhân tử: }"
        TEX_KHONG_THE = "\\text{Đa thức này không thể phân tích thêm thành nhân tử.}"

        try:
            # 1. Parsing bằng hàm chuẩn đã build
            _, lhs, rhs, _ = parse_equation(content)
            expr = lhs - rhs  # Đưa về dạng biểu thức để phân tích

            steps_latex = []
            steps_latex.append(f"{TEX_PHAN_TICH} {latex(expr)}")

            # 2. Phân tích nhân tử
            final_factored = factor(expr)

            # 3. Kiểm tra logic phân tích
            if final_factored == expr:
                steps_latex.append(f"{TEX_KHONG_THE}")
            else:
                steps_latex.append(f"\\text{{- Kết quả phân tích:}}")
                steps_latex.append(f"= {latex(final_factored)}")

            return {
                "result": str(final_factored),
                "latex": latex(final_factored),
                "steps_latex": steps_latex,
                "type": "factorization"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }