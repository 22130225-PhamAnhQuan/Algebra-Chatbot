from sympy import sympify, factor, gcd_terms, factor_terms


class FactorSolver:
    def solve(self, content: str):
        steps = []
        clean_content = content.replace("^", "**")
        expr = sympify(clean_content)

        steps.append(f"\\text{{Phân tích đa thức thành nhân tử: }} {content}")

        common_factor = gcd_terms(expr)
        if common_factor != 1 and common_factor != expr:
            factored_terms = factor_terms(expr)
            steps.append(f"\\text{{- Đặt nhân tử chung }} {common_factor}:")
            steps.append(f"= {factored_terms}")
            expr = factored_terms

        final_factored = factor(expr)

        if final_factored != expr:
            steps.append(f"\\text{{- Áp dụng các phương pháp (Hằng đẳng thức/Nhóm hạng tử):}}")
            steps.append(f"= {final_factored}")

        if final_factored == sympify(clean_content):
            steps.append(f"\\text{{Đa thức này không thể phân tích thêm thành nhân tử.}}")

        return {
            "result": f"{final_factored}",
            "latex": f"{final_factored}",
            "steps_latex": steps
        }