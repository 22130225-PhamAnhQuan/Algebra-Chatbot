import re
from sympy import factorint, lcm, latex

class LcmSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            nums = [int(s) for s in re.findall(r'\d+', content)]
            if len(nums) < 2:
                return {"result": "Lỗi", "steps_latex": [r"\text{Vui lòng nhập ít nhất 2 số (VD: 12, 15)}"]}

            a, b = nums[0], nums[1]
            steps_latex.append(f"\\text{{Tìm Bội chung nhỏ nhất: BCNN}}({a}, {b})")

            result = lcm(a, b)
            steps_latex.append(f"\\Rightarrow \\text{{BCNN}}({a}, {b}) = {result}")

            return {
                "result": str(result),
                "latex": str(result),
                "steps_latex": steps_latex,
                "type": "lcm"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}