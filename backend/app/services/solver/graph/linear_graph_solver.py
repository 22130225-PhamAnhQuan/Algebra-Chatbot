import numpy as np
from sympy import symbols, expand, latex, simplify, sympify
from .graph_utils import GraphUtils


class LinearGraphSolver:
    def solve(self, expr_str):
        x = symbols("x")
        clean_str = expr_str.lower().replace("y=", "").replace("y =", "").strip()
        expr = expand(sympify(clean_str))
        poly = expr.as_poly(x)
        a, b = poly.all_coeffs() if poly.degree() == 1 else (0, poly.all_coeffs()[0])

        steps_latex = []
        steps_latex.append(f"\\text{{Vẽ đồ thị hàm số (đường thẳng): }} y = {latex(expr)}")

        y_int = simplify(expr.subs(x, 0))
        if a != 0:
            x_int = simplify(-b / a)
            steps_latex.append(
                f"\\text{{- Cho }} x = 0 \\Rightarrow y = {latex(y_int)} \\text{{. Ta được điểm }} A(0; {latex(y_int)}) \\text{{ thuộc trục tung Oy.}}")
            steps_latex.append(
                f"\\text{{- Cho }} y = 0 \\Rightarrow x = {latex(x_int)} \\text{{. Ta được điểm }} B({latex(x_int)}; 0) \\text{{ thuộc trục hoành Ox.}}")
            steps_latex.append("\\text{- Kẻ đường thẳng đi qua hai điểm A và B, ta được đồ thị hàm số.}")
        else:
            steps_latex.append(
                f"\\text{{Đây là hàm hằng. Đồ thị là đường thẳng song song với trục Ox và đi qua điểm }} (0; {latex(y_int)})")

        fig, ax = GraphUtils.create_axes(f"Do thi y = {expr}")
        xs = np.linspace(-5, 5, 100)
        ys = [float(expr.subs(x, val)) for val in xs]

        ax.plot(xs, ys, color='blue', linewidth=2, label=f"y = {expr}")
        if a != 0:
            GraphUtils.mark_point(ax, 0, float(y_int), f"A(0, {y_int})")
            GraphUtils.mark_point(ax, float(x_int), 0, f"B({x_int}, 0)")
        ax.legend()

        image = GraphUtils.to_base64(fig)

        return {
            "result": f"y = {latex(expr)}",
            "latex": f"y = {latex(expr)}",
            "steps_latex": steps_latex,
            "image": image,
            "type": "linear"
        }