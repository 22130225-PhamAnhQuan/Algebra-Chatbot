import numpy as np
from sympy import symbols, sympify, latex, simplify
from .graph_utils import GraphUtils


class QuadraticGraphSolver:
    def solve(self, expr_str):
        x = symbols("x")
        clean_str = expr_str.lower().replace("y=", "").replace("y =", "").replace("^", "**").strip()
        expr = sympify(clean_str)
        poly = expr.as_poly(x)
        a = poly.coeff_monomial(x ** 2)

        steps_latex = []
        steps_latex.append(f"\\text{{Vẽ đồ thị hàm số (Parabol): }} y = {latex(expr)}")

        # 1. Tính chất
        direction = "lên trên" if a > 0 else "xuống dưới"
        steps_latex.append(f"\\text{{- Tập xác định: }} \\mathbb{{R}}")
        steps_latex.append(
            f"\\text{{- Bề lõm đồ thị hướng {direction} (do hệ số }} a = {latex(a)} {'>' if a > 0 else '<'} 0 \\text{{). Đỉnh là gốc tọa độ }} O(0;0)\\text{{.}}")

        # 2. Bảng giá trị
        x_vals = [-2, -1, 0, 1, 2]
        y_vals = [simplify(expr.subs(x, val)) for val in x_vals]

        table_latex = "\\begin{array}{|c|c|c|c|c|c|} \\hline "
        table_latex += "x & -2 & -1 & 0 & 1 & 2 \\\\ \\hline "
        table_latex += "y & " + " & ".join([latex(y) for y in y_vals]) + " \\\\ \\hline "
        table_latex += "\\end{array}"

        steps_latex.append(f"\\text{{- Bảng giá trị:}}")
        steps_latex.append(table_latex)
        steps_latex.append("\\text{- Vẽ đường cong Parabol đi qua 5 điểm trên ta được đồ thị hàm số.}")

        # 3. Vẽ bằng Matplotlib
        fig, ax = GraphUtils.create_axes(f"Parabol y = {expr}")
        xs = np.linspace(-4, 4, 200)
        ys = [float(expr.subs(x, val)) for val in xs]

        ax.plot(xs, ys, color='red', linewidth=2, label=f"y = {expr}")
        for xv, yv in zip(x_vals, y_vals):
            GraphUtils.mark_point(ax, float(xv), float(yv))
        GraphUtils.mark_point(ax, 0, 0, "O(0,0)")
        ax.legend()

        image = GraphUtils.to_base64(fig)

        return {
            "result": f"y = {latex(expr)}",
            "latex": f"y = {latex(expr)}",
            "steps_latex": steps_latex,
            "image": image,
            "type": "quadratic"
        }