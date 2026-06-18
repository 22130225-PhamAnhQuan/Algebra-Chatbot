import numpy as np
from sympy import symbols, latex, Poly
# Tận dụng lại bộ parser xịn xò đã làm
from app.services.solver.parser import parse_equation
from .graph_utils import GraphUtils


class QuadraticGraphSolver:
    def solve(self, expr_str):
        try:
            clean_str = expr_str.lower().replace("y=", "").replace("y =", "").strip()

            x, expr, _, _ = parse_equation(clean_str)

            # 2. Phân tích hệ số a, b, c an toàn tuyệt đối
            poly = Poly(expr, x)
            if poly.degree() != 2:
                raise ValueError("Hàm số nhập vào không phải là Parabol (bậc 2).")

            # Lấy hệ số đích danh theo bậc
            a = float(poly.coeff_monomial(x ** 2))
            b = float(poly.coeff_monomial(x))
            c = float(poly.coeff_monomial(1))

            # 3. Tính toán đỉnh và trục
            x_dinh = -b / (2 * a)
            y_dinh = float(expr.subs(x, x_dinh))

            # 4. các bước giải
            steps_latex = []
            steps_latex.append(f"\\text{{Vẽ đồ thị hàm số: }} y = {latex(expr)}")
            steps_latex.append(f"\\text{{1. Tập xác định: }} D = \\mathbb{{R}}")
            steps_latex.append(f"\\text{{2. Tọa độ đỉnh: }} I({x_dinh:.2f}; {y_dinh:.2f})")
            steps_latex.append(f"\\text{{3. Trục đối xứng: }} x = {x_dinh:.2f}")

            direction = "\\text{lên trên}" if a > 0 else "\\text{xuống dưới}"
            steps_latex.append(f"\\text{{4. Bề lõm: Hướng {direction} (do a = {a:.1f})}}")
            steps_latex.append(f"\\text{{   Giao điểm với trục tung Oy: }} (0; {c:.1f})")

            # 5. Tạo bảng giá trị
            x_vals = [x_dinh - 2.0, x_dinh - 1.0, x_dinh, x_dinh + 1.0, x_dinh + 2.0]
            y_vals = [float(expr.subs(x, v)) for v in x_vals]

            table_latex = "\\begin{array}{|c|c|c|c|c|c|} \\hline "
            table_latex += "x & " + " & ".join([f"{v:.1f}" for v in x_vals]) + " \\\\ \\hline "
            table_latex += "y & " + " & ".join([f"{v:.1f}" for v in y_vals]) + " \\\\ \\hline "
            table_latex += "\\end{array}"

            steps_latex.append(f"\\text{{5. Bảng giá trị:}}")
            steps_latex.append(table_latex)
            steps_latex.append("\\text{- Vẽ đường cong Parabol đi qua các điểm trên ta được đồ thị.}")

            # 6. Vẽ đồ thị
            fig, ax = GraphUtils.create_axes(f"Parabol y = {latex(expr)}")
            xs = np.linspace(x_dinh - 3, x_dinh + 3, 200)
            ys = [float(expr.subs(x, val)) for val in xs]

            ax.plot(xs, ys, color='red', linewidth=2, label=f"$y = {latex(expr)}$")
            GraphUtils.mark_point(ax, float(x_dinh), y_dinh, "I")
            for xv, yv in zip(x_vals, y_vals):
                GraphUtils.mark_point(ax, xv, yv)

            ax.legend()
            image_base64 = GraphUtils.to_base64(fig)

            return {
                "result": f"y = {latex(expr)}",
                "latex": f"y = {latex(expr)}",
                "steps_latex": steps_latex,
                "graph_image": image_base64,
                "type": "quadratic"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Hàm số không hợp lệ}",
                "steps_latex": [f"\\text{{Lỗi xử lý: {str(e)}}}",
                                "\\text{Gợi ý: Hãy nhập đúng định dạng, ví dụ: } y = 2x^2 - 3x + 1"],
                "graph_image": None,
                "type": "error"
            }