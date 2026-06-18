import re
from sympy import factorint


class PrimeFactorSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            nums = re.findall(r'\d+', content)
            if not nums: return {"result": "Lỗi", "steps_latex": [r"\text{Vui lòng nhập một số nguyên dương}"]}

            number = int(nums[0])
            factors = factorint(number)

            parts = []
            for p, e in factors.items():
                if e == 1:
                    parts.append(str(p))
                else:
                    parts.append(f"{p}^{{{e}}}")

            result_latex = " \\cdot ".join(parts)

            steps_latex.append(f"\\text{{Phân tích số }} {number} \\text{{ ra thừa số nguyên tố:}}")
            steps_latex.append(f"{number} = {result_latex}")

            return {
                "result": result_latex.replace(" \\cdot ", " x "),
                "latex": result_latex,
                "steps_latex": steps_latex,
                "type": "prime_factor"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}