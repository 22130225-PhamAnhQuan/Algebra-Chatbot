import re
from sympy import factorint, gcd

class GcdSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            nums = [int(s) for s in re.findall(r'\d+', content)]
            if len(nums) < 2:
                return {"result": "Lỗi", "steps_latex": [r"\text{Vui lòng nhập ít nhất 2 số (VD: 12, 15)}"]}

            a, b = nums[0], nums[1]

            def factor_latex(factors):
                parts = []
                for p, e in factors.items():
                    if e == 1: parts.append(str(p))
                    else: parts.append(f"{p}^{{{e}}}")
                return " \\cdot ".join(parts)

            steps_latex.append(f"\\text{{Tìm Ước chung lớn nhất: ƯCLN}}({a}, {b})")
            steps_latex.append(f"\\text{{- Phân tích ra thừa số nguyên tố:}}")
            steps_latex.append(f"{a} = {factor_latex(factorint(a))}")
            steps_latex.append(f"{b} = {factor_latex(factorint(b))}")

            gcd_value = gcd(a, b)
            steps_latex.append(f"\\Rightarrow \\text{{ƯCLN}}({a}, {b}) = {gcd_value}")

            return {
                "result": str(gcd_value),
                "latex": str(gcd_value),
                "steps_latex": steps_latex,
                "type": "gcd"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}