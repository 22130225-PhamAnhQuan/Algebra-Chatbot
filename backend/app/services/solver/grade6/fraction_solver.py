import re
from sympy import sympify, lcm, latex

class FractionArithmeticSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            clean_content = content.replace(":", "/").replace("÷", "/").replace("×", "*")

            expr = sympify(clean_content, evaluate=False)
            steps_latex.append(f"\\text{{Thực hiện phép tính phân số: }} {latex(expr)}")

            denominators = [int(m[1]) for m in re.findall(r'(\d+)/(\d+)', clean_content)]

            if len(denominators) >= 2:
                msc = denominators[0]
                for d in denominators[1:]:
                    msc = lcm(msc, d)
                steps_latex.append(f"\\text{{- Mẫu số chung (BCNN các mẫu): }} {msc}")
                steps_latex.append(f"\\text{{- Quy đồng mẫu số và tính toán:}}")

            result = sympify(clean_content)
            steps_latex.append(f"= {latex(result)}")

            return {
                "result": str(result),
                "latex": latex(result),
                "steps_latex": steps_latex,
                "type": "fraction_arithmetic"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}