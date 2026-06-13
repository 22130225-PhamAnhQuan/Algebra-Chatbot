from sympy import Rational


class RatioSolver:
    def solve(self, content: str):
        steps = []
        clean_str = content.strip().replace(":", "/")
        parts = [p.strip() for p in clean_str.split("/") if p.strip()]

        if len(parts) != 2:
            return {"result": "Lỗi", "steps_latex": ["\\text{Định dạng chuẩn là a:b hoặc a/b}"]}

        a, b = int(parts[0]), int(parts[1])
        ratio = Rational(a, b)

        steps.append(f"\\text{{Theo định nghĩa, tỉ số của {a} và {b} được viết là:}}")
        steps.append(f"\\frac{{{a}}}{{{b}}}")
        steps.append(f"\\text{{Rút gọn về phân số tối giản ta được:}}")
        steps.append(f"= {ratio}")

        return {
            "result": f"{ratio}",
            "latex": f"{ratio}",
            "steps_latex": steps
        }