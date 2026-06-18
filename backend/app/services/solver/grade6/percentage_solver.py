import re
from sympy import Rational, latex


class PercentageSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            nums = [int(s) for s in re.findall(r'\d+', content)]
            if len(nums) < 2:
                return {"result": "Lỗi", "steps_latex": [r"\text{Vui lòng nhập định dạng: x\% của y}"]}

            percent, value = nums[0], nums[1]
            fraction = Rational(percent, 100)
            result = fraction * value

            steps_latex.append(
                f"\\text{{Muốn tìm }} {percent}\\% \\text{{ của }} {value}\\text{{, ta thực hiện phép tính:}}")
            steps_latex.append(f"{value} \\cdot \\frac{{{percent}}}{{100}}")

            if fraction.q != 100:  # Nếu phân số rút gọn được
                steps_latex.append(f"= {value} \\cdot {latex(fraction)}")

            steps_latex.append(f"= {latex(result)}")

            return {
                "result": str(result),
                "latex": latex(result),
                "steps_latex": steps_latex,
                "type": "percentage"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}