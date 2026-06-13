import re
from sympy import sympify, together, cancel, Rational
from math import lcm


class FractionArithmeticSolver:
    def solve(self, content: str):
        steps = []
        clean_content = content.replace(":", "/").replace("÷", "/").replace("×", "*")

        steps.append(f"\\text{{Biểu thức phân số: }} {content}")

        denominators = [int(m[1]) for m in re.findall(r'(\d+)/(\d+)', clean_content)]

        if len(denominators) >= 2:
            msc = lcm(*denominators)
            steps.append(f"\\text{{- Mẫu số chung (BCNN): }} {msc}")

            expr = sympify(clean_content, evaluate=False)
            steps.append(f"\\text{{- Quy đồng mẫu số và thực hiện tính toán:}}")

        result = sympify(clean_content)  # Tính ra phân số tối giản bằng SymPy
        steps.append(f"= {result}")

        return {
            "result": f"{result}",
            "latex": f"{result}",
            "steps_latex": steps
        }