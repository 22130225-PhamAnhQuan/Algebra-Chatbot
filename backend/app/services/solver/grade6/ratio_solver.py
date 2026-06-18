from sympy import Rational, latex

class RatioSolver:
    def solve(self, content: str):
        try:
            steps_latex = []
            clean_str = content.strip().replace(":", "/")
            parts = [p.strip() for p in clean_str.split("/") if p.strip()]

            if len(parts) != 2:
                return {"result": "Lỗi", "steps_latex": [r"\text{Định dạng chuẩn là a:b hoặc a/b}"]}

            a, b = int(parts[0]), int(parts[1])
            ratio = Rational(a, b)

            steps_latex.append(f"\\text{{Theo định nghĩa, tỉ số của }} {a} \\text{{ và }} {b} \\text{{ được viết là:}}")
            steps_latex.append(f"\\frac{{{a}}}{{{b}}}")
            steps_latex.append(f"\\text{{Rút gọn về phân số tối giản ta được:}}")
            steps_latex.append(f"= {latex(ratio)}")

            return {
                "result": str(ratio),
                "latex": latex(ratio),
                "steps_latex": steps_latex,
                "type": "ratio"
            }
        except Exception as e:
            return {"result": "Lỗi", "latex": "\\text{Lỗi dữ liệu}", "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]}