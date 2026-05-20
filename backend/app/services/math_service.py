# # app/services/math_service.py
# #
# # Dùng cho math_router.py:
# #   POST /math/solve   → solve_linear_equation()
# #   POST /math/graph   → plot_graph()
# #
# import re
# import base64
# import io
#
# from sympy import symbols, solve, Eq
# from sympy.parsing.sympy_parser import (
#     parse_expr,
#     standard_transformations,
#     implicit_multiplication_application,
# )
#
# from app.services.solver import detect, ProblemType
# from app.services.solver.linear_solver    import solve_linear
# from app.services.solver.quadratic_solver import solve_quadratic
# from app.services.solver.system_solver    import solve_system
#
#
# # ─── solve_linear_equation ────────────────────────────────────────────────────
#
# def solve_linear_equation(content: str) -> dict:
#     """
#     Tự động detect và giải — dùng cho endpoint /math/solve (quick, không cần user_id)
#     """
#     content = content.strip()
#     problem_type = detect(content)
#
#     try:
#         if problem_type == ProblemType.LINEAR:
#             result = solve_linear(content)
#         elif problem_type == ProblemType.QUADRATIC:
#             result = solve_quadratic(content)
#         elif problem_type == ProblemType.SYSTEM:
#             result = solve_system(content)
#         else:
#             # Bài toán phức tạp — trả về gợi ý dùng /solve/math (có AI)
#             return {
#                 "success": False,
#                 "message": "Bài toán này phức tạp, vui lòng dùng endpoint /solve/math",
#                 "problem_type": problem_type.value,
#             }
#
#         return {
#             "success":      True,
#             "problem_type": problem_type.value,
#             "result":       result.get("result", ""),
#             "steps":        result.get("steps", []),
#         }
#
#     except ValueError as e:
#         return {"success": False, "error": str(e)}
#
#
# # ─── plot_graph ───────────────────────────────────────────────────────────────
#
# def plot_graph(expression: str) -> dict:
#     """
#     Vẽ đồ thị hàm số y = f(x).
#     Trả về base64 PNG để Flutter hiển thị.
#
#     Ví dụ expression: "x^2 - 4", "2*x + 1", "x^3 - 3*x"
#     """
#     try:
#         import matplotlib
#         matplotlib.use("Agg")  # non-interactive backend
#         import matplotlib.pyplot as plt
#         import numpy as np
#
#         expression = _normalize_expr(expression)
#
#         x_vals = np.linspace(-10, 10, 500)
#         y_vals = _evaluate(expression, x_vals)
#
#         fig, ax = plt.subplots(figsize=(7, 4))
#         ax.plot(x_vals, y_vals, color="#5B5FEF", linewidth=2.5, label=f"y = {expression}")
#
#         # Trục toạ độ
#         ax.axhline(0, color="#1E1F4B", linewidth=0.8, linestyle="--", alpha=0.5)
#         ax.axvline(0, color="#1E1F4B", linewidth=0.8, linestyle="--", alpha=0.5)
#
#         ax.set_xlabel("x", fontsize=12)
#         ax.set_ylabel("y", fontsize=12)
#         ax.set_title(f"Đồ thị: y = {expression}", fontsize=13, fontweight="bold")
#         ax.legend(fontsize=10)
#         ax.grid(True, alpha=0.3)
#         ax.set_ylim(-20, 20)
#
#         plt.tight_layout()
#
#         # Encode sang base64
#         buf = io.BytesIO()
#         plt.savefig(buf, format="png", dpi=120, bbox_inches="tight")
#         plt.close(fig)
#         buf.seek(0)
#         img_base64 = base64.b64encode(buf.read()).decode("utf-8")
#
#         return {
#             "success":    True,
#             "expression": expression,
#             "image":      img_base64,        # base64 PNG
#             "image_url":  None,              # nếu upload S3 thì điền vào đây
#         }
#
#     except ImportError:
#         return {
#             "success": False,
#             "error":   "matplotlib chưa được cài. Chạy: pip install matplotlib",
#         }
#     except Exception as e:
#         return {"success": False, "error": f"Không thể vẽ đồ thị: {e}"}
#
#
# # ─── Helpers ──────────────────────────────────────────────────────────────────
#
# def _normalize_expr(expr: str) -> str:
#     expr = expr.strip().lower()
#     expr = expr.replace("^", "**").replace("×", "*").replace("÷", "/")
#     expr = re.sub(r"(\d)([a-z])", r"\1*\2", expr)
#     return expr
#
#
# def _evaluate(expression: str, x_vals):
#     import numpy as np
#     # Map các hàm toán học
#     safe_globals = {
#         "x":    x_vals,
#         "sin":  np.sin,  "cos":  np.cos,  "tan":  np.tan,
#         "sqrt": np.sqrt, "log":  np.log,  "exp":  np.exp,
#         "abs":  np.abs,  "pi":   np.pi,   "e":    np.e,
#     }
#     try:
#         y = eval(expression, {"__builtins__": {}}, safe_globals)  # noqa: S307
#         # Clamp vô cực về NaN để matplotlib bỏ qua
#         y = np.where(np.isfinite(y), y, np.nan)
#         return y
#     except Exception:
#         import numpy as np
#         return np.full_like(x_vals, np.nan)
