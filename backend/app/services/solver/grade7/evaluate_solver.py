from sympy import symbols, sympify, simplify, latex
from app.services.solver.parser import normalize


class EvaluateSolver:
    def solve(self, content: str):
        TEX_TA_CO = "\\text{Ta có: }"
        TEX_THAY = "\\text{- Thay }"
        TEX_VAO = "\\text{ vào biểu thức:}"
        TEX_GIA_TRI = "\\text{Vậy giá trị của biểu thức là: }"

        try:
            expr_str, var_name, value = self.parse_input(content)
            x = symbols(var_name)

            # Dùng normalize để biến 2x thành 2*x
            clean_expr_str = normalize(expr_str)
            expr = sympify(clean_expr_str)

            steps_latex = []
            steps_latex.append(f"{TEX_TA_CO} A = {latex(expr)}")

            steps_latex.append(f"{TEX_THAY} {var_name} = {latex(value)} {TEX_VAO}")

            substituted = expr.subs(x, value)
            steps_latex.append(f"A = {latex(substituted)}")

            result = simplify(substituted)
            if result != substituted:
                steps_latex.append(f"= {latex(result)}")

            steps_latex.append(f"{TEX_GIA_TRI} A = {latex(result)}")

            return {
                "result": f"A = {result}",
                "latex": f"A = {latex(result)}",
                "steps_latex": steps_latex,
                "type": "evaluate"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi xử lý: {str(e)}}}"]
            }

    def parse_input(self, content):
        content = content.lower().replace("^", "**").replace("²", "**2")

        split_keyword = next((kw for kw in ["tại", "với", "khi"] if kw in content), None)
        if not split_keyword:
            raise Exception("Thiếu từ khóa 'tại' hoặc 'với' (VD: Tính 2x tại x=1)")

        expr_part, value_part = content.split(split_keyword, 1)
        expr_part = expr_part.replace("tính giá trị biểu thức", "").replace("a=", "").replace("a =", "").strip()

        var_name, value_str = value_part.replace(" ", "").split("=")

        return expr_part, var_name, sympify(value_str)