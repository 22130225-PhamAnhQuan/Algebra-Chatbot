from sympy import Rational, re


class PercentageSolver:
    def solve(self, content: str):
        steps = []
        nums = [int(s) for s in re.findall(r'\d+', content)]
        if len(nums) < 2:
            return {"result": "Lỗi", "steps_latex": ["\\text{Vui lòng nhập đúng định dạng: x% của y}"]}

        percent, value = nums[0], nums[1]
        fraction = Rational(percent, 100)
        result = fraction * value

        steps.append(f"\\text{{Muốn tìm {percent}\\% của {value}, ta thực hiện phép tính:}}")
        steps.append(f"{value} \\cdot \\frac{{{percent}}}{{100}}")
        steps.append(f"= {value} \\cdot {fraction}")
        steps.append(f"= {result}")

        return {
            "result": f"{result}",
            "latex": f"{result}",
            "steps_latex": steps
        }