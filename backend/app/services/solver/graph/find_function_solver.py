from sympy import *


class FindFunctionSolver:
    def solve(self, content: str): # Sửa tham số thành content
        steps = []

        matches = re.findall(r"\(\s*([-]?\d+)\s*[;,]\s*([-]?\d+)\s*\)", content)

        if len(matches) != 2:
            return {
                "result": "Lỗi",
                "steps": ["Không tìm đủ 2 điểm."],
                "steps_latex": [r"\text{Vui lòng nhập đúng tọa độ 2 điểm, ví dụ: đi qua A(1; 2) và B(3; 4)}"]
            }

        x1, y1 = float(matches[0][0]), float(matches[0][1])
        x2, y2 = float(matches[1][0]), float(matches[1][1])

        a, b = symbols("a b")

        steps.append(
            "Giả sử hàm số có dạng:"
        )

        steps.append(
            "y = ax + b"
        )

        eq1 = Eq(
            a * x1 + b,
            y1
        )

        eq2 = Eq(
            a * x2 + b,
            y2
        )

        steps.append(
            f"{x1}a + b = {y1}"
        )

        steps.append(
            f"{x2}a + b = {y2}"
        )

        solution = solve(
            (eq1, eq2),
            (a, b)
        )

        a_value = simplify(
            solution[a]
        )

        b_value = simplify(
            solution[b]
        )

        steps.append(
            f"a = {a_value}"
        )

        steps.append(
            f"b = {b_value}"
        )

        steps.append(
            f"Vậy hàm số là:"
        )

        steps.append(
            f"y = {a_value}x + ({b_value})"
        )

        return {
            "result": f"y = {a_value}x + ({b_value})",
            "steps": steps,
            "steps_latex": [r"\text{" + s + "}" for s in steps],
            "function": {
                "a": str(a_value),
                "b": str(b_value)
            }
        }
