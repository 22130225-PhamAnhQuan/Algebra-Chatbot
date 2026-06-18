from sympy import symbols, expand, simplify, solve, latex, Interval, Union
from app.services.solver.parser import parse_equation


class InequalitySolver:
    def solve(self, content: str):
        try:
            x, lhs, rhs, var = parse_equation(content)
            expr = simplify(lhs - rhs)

            # Xác định toán tử từ content gốc (để hiển thị đúng bước 1)
            op = next(o for o in ["<=", ">=", "<", ">"] if o in content)

            steps_latex = []
            steps_latex.append(
                f"\\text{{Giải bất phương trình: }} {latex(lhs)} {op.replace('<', '<').replace('>', '>')} {latex(rhs)}")
            steps_latex.append(f"\\Leftrightarrow {latex(expr)} {op.replace('<', '<').replace('>', '>')} 0")

            # Sử dụng solve của SymPy
            if op == "<=":
                condition = expr <= 0
            elif op == ">=":
                condition = expr >= 0
            elif op == "<":
                condition = expr < 0
            else:
                condition = expr > 0

            solution_set = solve(condition, x, real=True)

            # Format kết quả cho Flutter
            result_latex = latex(solution_set)

            steps_latex.append(f"\\text{{Tập nghiệm của bất phương trình là: }} S = {result_latex}")

            return {
                "result": f"S = {str(solution_set).replace('oo', '∞')}",
                "latex": f"S = {result_latex}",
                "steps_latex": steps_latex,
                "type": "inequality"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": r"\text{Lỗi cú pháp hoặc hệ thống}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }