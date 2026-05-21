# app/services/solver/graph_solver.py
#
# Tất cả dạng đồ thị chương trình THCS:
#   1. Hàm bậc nhất       y = ax + b
#   2. Hàm y = ax²         (lớp 7)
#   3. Hàm bậc hai         y = ax² + bx + c
#   4. Hai đồ thị + giao điểm
#   5. Tìm hệ số từ đồ thị  (cho 2 điểm → tìm a, b)
#   6. Bảng giá trị         (hàm rời rạc)
#
import re, io, base64
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

from sympy import (
    symbols, Rational, sqrt, solve as sym_solve,
    Eq, simplify, expand,
)
from sympy.parsing.sympy_parser import (
    parse_expr, standard_transformations,
    implicit_multiplication_application,
)


# ─── Entry point ──────────────────────────────────────────────────────────────

def solve_graph(content: str) -> dict:
    """
    Router chính — tự nhận dạng dạng yêu cầu rồi dispatch.

    Các pattern nhận dạng:
      - "y = ax + b" / "y = ax²"          → bậc 1 hoặc bậc 2
      - "vẽ y=... và y=..."               → two_functions
      - "tìm a, b biết ..." / "đi qua"   → find_coefficients
      - "bảng giá trị" / x=...,y=...     → value_table
    """
    text = content.strip().lower()

    if _is_two_functions(text):
        return graph_two_functions(content)

    if _is_find_coefficients(text):
        return graph_find_coefficients(content)

    if _is_value_table(text):
        return graph_value_table(content)

    # Đơn hàm số — parse rồi phân bậc
    expr_str, degree = _parse_single_function(content)

    if degree == 1:
        return graph_linear(content, expr_str)
    elif degree == 2:
        a_coeff = _get_leading_coeff(expr_str)
        # Lớp 7: y = ax² (không có bx + c)
        if _is_simple_quadratic(expr_str):
            return graph_simple_quadratic(content, expr_str)
        return graph_quadratic(content, expr_str)
    else:
        raise ValueError(
            "Không nhận dạng được hàm số. "
            "Ví dụ hợp lệ: 'y = 2x + 1', 'y = x² - 3x + 2', "
            "'vẽ y=2x+1 và y=x-3', 'tìm a,b biết đồ thị đi qua (1;3) và (2;5)'"
        )


# ═══════════════════════════════════════════════════════════════════════════════
# 1. HÀM BẬC NHẤT  y = ax + b
# ═══════════════════════════════════════════════════════════════════════════════

def graph_linear(original: str, expr_str: str) -> dict:
    x = symbols("x")
    expr = _parse_expr(expr_str, x)

    poly = expand(expr).as_poly(x)
    coeffs = poly.all_coeffs() if poly else [1, 0]
    a = float(coeffs[0]) if len(coeffs) > 0 else 1
    b = float(coeffs[1]) if len(coeffs) > 1 else 0

    x_int = (-b / a) if a != 0 else None
    y_int = b

    steps = [
        f"Hàm số bậc nhất: y = {expr}",
        f"Bước 1: Hệ số  a = {a},  b = {b}",
        f"Bước 2: Giao Oy (x=0) → (0; {y_int:.4g})",
    ]
    if x_int is not None:
        steps.append(f"Bước 3: Giao Ox (y=0) → ({x_int:.4g}; 0)")
    steps += [
        f"Nhận xét: {'Đồng biến ↗' if a > 0 else 'Nghịch biến ↘' if a < 0 else 'Hằng số —'}  (a {'>' if a>0 else '<' if a<0 else '='} 0)",
        f"✅ Đồ thị: Đường thẳng qua (0; {y_int:.4g})" +
        (f" và ({x_int:.4g}; 0)" if x_int is not None else ""),
    ]

    # Vẽ
    cx = x_int if x_int is not None else 0
    x_vals = np.linspace(cx - 5, cx + 5, 400)
    y_vals = a * x_vals + b

    fig, ax = _base_axes(f"y = {expr}")
    ax.plot(x_vals, y_vals, color=_C[0], linewidth=2.5, label=f"y = {expr}", zorder=3)
    _mark(ax, 0, y_int, f"(0; {y_int:.4g})", _C[0])
    if x_int is not None:
        _mark(ax, x_int, 0, f"({x_int:.4g}; 0)", _C[1])
    ax.legend(fontsize=10)

    return {
        "success": True, "result": f"Đường thẳng y = {expr}", "steps": steps,
        "image": _to_base64(fig), "degree": 1, "solver": "graph_linear",
        "features": {
            "a": a, "b": b,
            "x_intercept": round(x_int, 6) if x_int is not None else None,
            "y_intercept": round(y_int, 6),
            "monotone": "increasing" if a > 0 else "decreasing" if a < 0 else "constant",
        },
    }


# ═══════════════════════════════════════════════════════════════════════════════
# 2. HÀM y = ax²  (lớp 7 — parabol đơn giản qua gốc tọa độ)
# ═══════════════════════════════════════════════════════════════════════════════

def graph_simple_quadratic(original: str, expr_str: str) -> dict:
    x = symbols("x")
    expr = _parse_expr(expr_str, x)
    poly = expand(expr).as_poly(x)
    a = float(poly.all_coeffs()[0])

    steps = [
        f"Hàm số: y = {expr}  (dạng y = ax²)",
        f"Bước 1: Hệ số  a = {a}",
        f"Bước 2: Đỉnh tại gốc tọa độ O(0; 0)",
        f"Bước 3: Trục đối xứng là trục Oy (x = 0)",
        f"Bước 4: Lập bảng giá trị",
        "   x:  -3   -2   -1   0   1   2   3",
        f"   y:  {a*9:.3g}  {a*4:.3g}  {a:.3g}  0  {a:.3g}  {a*4:.3g}  {a*9:.3g}",
        f"Nhận xét: Parabol mở {'lên ↑ (a>0)' if a>0 else 'xuống ↓ (a<0)'}",
        f"✅ Đồ thị: Parabol đỉnh O(0;0), mở {'lên' if a>0 else 'xuống'}",
    ]

    x_vals = np.linspace(-4, 4, 400)
    y_vals = a * x_vals**2
    fig, ax = _base_axes(f"y = {expr}")
    ax.plot(x_vals, y_vals, color=_C[0], linewidth=2.5, label=f"y = {expr}", zorder=3)
    _mark(ax, 0, 0, "O(0; 0)", _C[1], marker="*", size=12)
    # Bảng giá trị mẫu
    xs_tbl = [-2, -1, 0, 1, 2]
    for xv in xs_tbl:
        _mark(ax, xv, a*xv**2, "", _C[0], size=5)
    ax.set_ylim(min(-1, a*16)*1.1, max(1, a*16)*1.1)
    ax.legend(fontsize=10)

    return {
        "success": True, "result": f"Parabol y = {expr} đỉnh O(0;0)",
        "steps": steps, "image": _to_base64(fig),
        "degree": 2, "solver": "graph_simple_quadratic",
        "features": {"a": a, "vertex": {"x": 0, "y": 0}, "axis": 0,
                     "opens": "up" if a > 0 else "down"},
    }


# ═══════════════════════════════════════════════════════════════════════════════
# 3. HÀM BẬC HAI  y = ax² + bx + c
# ═══════════════════════════════════════════════════════════════════════════════

def graph_quadratic(original: str, expr_str: str) -> dict:
    x = symbols("x")
    expr = _parse_expr(expr_str, x)
    poly = expand(expr).as_poly(x)
    coeffs = poly.all_coeffs() if poly else [1, 0, 0]
    a = float(coeffs[0]) if len(coeffs) > 0 else 1
    b = float(coeffs[1]) if len(coeffs) > 1 else 0
    c = float(coeffs[2]) if len(coeffs) > 2 else 0

    delta = b**2 - 4*a*c
    x_vt  = -b / (2*a)
    y_vt  = a*x_vt**2 + b*x_vt + c

    x_roots = []
    if delta > 0:
        x_roots = sorted([(-b + delta**0.5)/(2*a), (-b - delta**0.5)/(2*a)])
    elif abs(delta) < 1e-9:
        x_roots = [x_vt]

    steps = [
        f"Hàm số bậc hai: y = {expr}",
        f"Bước 1: Hệ số  a={a},  b={b},  c={c}",
        f"Bước 2: Delta  Δ = b²-4ac = {b}²-4×{a}×{c} = **{delta:.6g}**",
        f"Bước 3: Đỉnh",
        f"   x₀ = -b/2a = -{b}/(2×{a}) = {x_vt:.4g}",
        f"   y₀ = {y_vt:.4g}  →  Đỉnh: ({x_vt:.4g}; {y_vt:.4g})",
        f"Bước 4: Trục đối xứng  x = {x_vt:.4g}",
        f"Bước 5: Giao Oy (x=0)  → (0; {c:.4g})",
        f"Bước 6: Giao Ox (y=0)",
    ]
    if delta > 0:
        steps.append(f"   Δ>0 → 2 nghiệm: x₁={x_roots[0]:.4g},  x₂={x_roots[1]:.4g}")
    elif abs(delta) < 1e-9:
        steps.append(f"   Δ=0 → nghiệm kép  x = {x_vt:.4g}")
    else:
        steps.append("   Δ<0 → không cắt Ox")

    direction = "lên ↑ (a>0)" if a > 0 else "xuống ↓ (a<0)"
    steps += [
        f"📌 Nhận xét: Parabol mở {direction}",
        f"   {'min' if a>0 else 'max'} y = {y_vt:.4g} tại x = {x_vt:.4g}",
        f"✅ Đồ thị: Parabol đỉnh ({x_vt:.4g}; {y_vt:.4g}), mở {'lên' if a>0 else 'xuống'}",
    ]

    spread = max(abs(x_vt)+5, 5)
    x_vals = np.linspace(x_vt-spread, x_vt+spread, 600)
    y_vals = a*x_vals**2 + b*x_vals + c

    fig, ax = _base_axes(f"y = {expr}")
    ax.plot(x_vals, y_vals, color=_C[0], linewidth=2.5, label=f"y = {expr}", zorder=3)
    ax.axvline(x_vt, color="#94A3B8", lw=1, ls="--", label=f"x = {x_vt:.4g}", zorder=2)
    _mark(ax, x_vt, y_vt, f"Đỉnh ({x_vt:.4g}; {y_vt:.4g})", _C[2], marker="*", size=12)
    _mark(ax, 0, c, f"(0; {c:.4g})", _C[0])
    for xr in x_roots:
        _mark(ax, xr, 0, f"({xr:.4g}; 0)", _C[1])
    rng = abs(y_vt) + spread*abs(a)*spread
    ax.set_ylim(y_vt - rng*0.25, y_vt + rng*0.6)
    ax.legend(fontsize=9)

    return {
        "success": True, "result": f"Parabol đỉnh ({x_vt:.4g}; {y_vt:.4g})",
        "steps": steps, "image": _to_base64(fig),
        "degree": 2, "solver": "graph_quadratic",
        "features": {
            "a": a, "b": b, "c": c, "delta": round(delta, 6),
            "vertex": {"x": round(x_vt, 6), "y": round(y_vt, 6)},
            "axis": round(x_vt, 6),
            "x_intercepts": [round(r, 6) for r in x_roots],
            "y_intercept": round(c, 6),
            "opens": "up" if a > 0 else "down",
        },
    }


# ═══════════════════════════════════════════════════════════════════════════════
# 4. HAI ĐỒ THỊ + GIAO ĐIỂM
#    Input: "vẽ y = 2x+1 và y = x²-3" hoặc "y=2x+1, y=x-3"
# ═══════════════════════════════════════════════════════════════════════════════

def graph_two_functions(content: str) -> dict:
    exprs = _extract_two_functions(content)
    if len(exprs) < 2:
        raise ValueError("Không tách được 2 hàm số. "
                         "Ví dụ: 'vẽ y = 2x+1 và y = x-3'")

    e1_str, e2_str = exprs[0], exprs[1]
    x = symbols("x")
    e1 = _parse_expr(e1_str, x)
    e2 = _parse_expr(e2_str, x)

    # Tìm giao điểm: e1 = e2
    intersections = sym_solve(Eq(e1, e2), x)
    inter_points = []
    for xi in intersections:
        try:
            xf = float(xi.evalf())
            yf = float(e1.subs(x, xi).evalf())
            inter_points.append((round(xf, 4), round(yf, 4)))
        except Exception:
            pass

    steps = [
        f"📌 Hàm số 1: y = {e1}",
        f"📌 Hàm số 2: y = {e2}",
        f"📌 Tìm giao điểm: Giải  {e1} = {e2}",
    ]
    if inter_points:
        for i, (xp, yp) in enumerate(inter_points, 1):
            steps.append(f"   Giao điểm {i}: ({xp}; {yp})")
    else:
        steps.append("   Hai đồ thị không giao nhau")
    steps.append(f"✅ Kết quả: {len(inter_points)} giao điểm")

    # Vẽ
    all_x = [p[0] for p in inter_points] + [0]
    cx = sum(all_x) / len(all_x)
    x_vals = np.linspace(cx - 7, cx + 7, 600)

    def safe_eval(expr_sym, xs):
        ys = []
        for xv in xs:
            try:
                ys.append(float(expr_sym.subs(x, xv).evalf()))
            except Exception:
                ys.append(np.nan)
        return np.array(ys)

    y1 = safe_eval(e1, x_vals)
    y2 = safe_eval(e2, x_vals)

    fig, ax = _base_axes(f"y = {e1}  và  y = {e2}")
    ax.plot(x_vals, y1, color=_C[0], lw=2.5, label=f"y = {e1}")
    ax.plot(x_vals, y2, color=_C[1], lw=2.5, label=f"y = {e2}")
    for xp, yp in inter_points:
        ax.plot(xp, yp, "o", color=_C[2], markersize=9, zorder=5,
                markeredgecolor="white", markeredgewidth=1.5)
        ax.annotate(f"({xp}; {yp})", (xp, yp),
                    xytext=(8, 8), textcoords="offset points", fontsize=9,
                    color=_C[2],
                    bbox=dict(boxstyle="round,pad=0.2", fc="white",
                              alpha=0.85, ec=_C[2]))
    ax.legend(fontsize=9)
    # Clamp y để tránh phóng to quá
    ys_finite = np.concatenate([y1[np.isfinite(y1)], y2[np.isfinite(y2)]])
    if len(ys_finite):
        ax.set_ylim(np.percentile(ys_finite, 2), np.percentile(ys_finite, 98))

    return {
        "success": True,
        "result": (f"{len(inter_points)} giao điểm: "
                   + ", ".join(f"({x};{y})" for x, y in inter_points)
                   if inter_points else "Không có giao điểm"),
        "steps": steps, "image": _to_base64(fig),
        "degree": "mixed", "solver": "graph_two_functions",
        "features": {"intersections": inter_points},
    }


# ═══════════════════════════════════════════════════════════════════════════════
# 5. TÌM HỆ SỐ TỪ ĐỒ THỊ
#    Input: "tìm a,b biết đồ thị y=ax+b đi qua (1;3) và (2;5)"
#           "tìm a biết đồ thị y=ax² đi qua (-2;8)"
# ═══════════════════════════════════════════════════════════════════════════════

def graph_find_coefficients(content: str) -> dict:
    points = _extract_points(content)
    if not points:
        raise ValueError("Không tìm được tọa độ điểm. "
                         "Ví dụ: 'y=ax+b đi qua (1;3) và (2;5)'")

    # Xác định dạng hàm trong đề
    text = content.lower()
    is_quadratic = bool(re.search(r"ax[²\^2]|bậc 2|parabol", text))

    a, b_val = symbols("a b")

    if is_quadratic and len(points) >= 1:
        return _find_coeff_quadratic(content, points)
    elif len(points) >= 2:
        return _find_coeff_linear(content, points)
    elif len(points) == 1:
        # Chỉ có 1 điểm và hàm bậc nhất → chỉ tìm được quan hệ a,b
        raise ValueError("Cần ít nhất 2 điểm để xác định hàm bậc nhất y=ax+b")
    else:
        raise ValueError("Không đủ điểm để tìm hệ số")


def _find_coeff_linear(content: str, points: list) -> dict:
    """Tìm a, b của y = ax + b từ 2 điểm"""
    (x1, y1), (x2, y2) = points[0], points[1]

    if x1 == x2:
        raise ValueError(f"Hai điểm ({x1};{y1}) và ({x2};{y2}) có cùng hoành độ "
                         "→ không xác định được hàm bậc nhất")

    a_val = (y2 - y1) / (x2 - x1)
    b_val = y1 - a_val * x1

    steps = [
        f"Đề bài: Tìm a, b biết y = ax + b đi qua ({x1}; {y1}) và ({x2}; {y2})",
        f"Bước 1: Thay ({x1}; {y1}) vào:  {y1} = {x1}a + b  ...(1)",
        f"Bước 2: Thay ({x2}; {y2}) vào:  {y2} = {x2}a + b  ...(2)",
        f"Bước 3: (2)-(1): {y2-y1} = {x2-x1}a  →  a = {a_val:.6g}",
        f"Bước 4: Thay a vào (1): b = {y1} - {a_val:.6g}×{x1} = {b_val:.6g}",
        f"Kiểm tra:",
        f"   x={x1}: y = {a_val:.4g}×{x1} + {b_val:.4g} = {a_val*x1+b_val:.4g} ✓",
        f"   x={x2}: y = {a_val:.4g}×{x2} + {b_val:.4g} = {a_val*x2+b_val:.4g} ✓",
        f"✅ Kết quả: a = {a_val:.6g},  b = {b_val:.6g}",
        f"   Hàm số: y = {a_val:.4g}x + {b_val:.4g}",
    ]

    # Vẽ đường thẳng tìm được
    expr_str = f"{a_val:.6g}*x + {b_val:.6g}"
    result_graph = graph_linear(f"y = {expr_str}", expr_str)
    # Thêm 2 điểm đã cho
    fig = _decode_and_replot_linear(a_val, b_val, points)

    return {
        "success": True,
        "result":  f"a = {a_val:.6g},  b = {b_val:.6g}  →  y = {a_val:.4g}x + {b_val:.4g}",
        "steps":   steps,
        "image":   _to_base64(fig),
        "degree":  1,
        "solver":  "graph_find_linear",
        "features": {"a": round(a_val, 6), "b": round(b_val, 6)},
    }


def _find_coeff_quadratic(content: str, points: list) -> dict:
    """Tìm a của y = ax² từ 1 điểm"""
    x1, y1 = points[0]
    if x1 == 0:
        raise ValueError("Điểm có x=0 không xác định được a trong y=ax²")
    a_val = y1 / (x1**2)

    steps = [
        f"Đề bài: Tìm a biết y = ax² đi qua ({x1}; {y1})",
        f"Bước 1: Thay ({x1}; {y1}) vào:  {y1} = a×{x1}²  = {x1**2}a",
        f"Bước 2: a = {y1}/{x1**2} = {a_val:.6g}",
        f"Kiểm tra: x={x1}: y = {a_val:.4g}×{x1**2} = {a_val*x1**2:.4g} ✓",
        f"✅ Kết quả: a = {a_val:.6g}  →  y = {a_val:.4g}x²",
    ]

    expr_str = f"{a_val:.6g}*x**2"
    result_graph = graph_simple_quadratic(f"y = {expr_str}", expr_str)

    return {
        **result_graph,
        "steps": steps,
        "result": f"a = {a_val:.6g}  →  y = {a_val:.4g}x²",
        "solver": "graph_find_quadratic",
        "features": {"a": round(a_val, 6)},
    }


# ═══════════════════════════════════════════════════════════════════════════════
# 6. BẢNG GIÁ TRỊ  (hàm rời rạc / tự cho x)
#    Input: "vẽ đồ thị với bảng giá trị x=-2,-1,0,1,2 y=4,1,0,1,4"
#           hoặc "lập bảng giá trị y=x²-2x, x từ -2 đến 3"
# ═══════════════════════════════════════════════════════════════════════════════

def graph_value_table(content: str) -> dict:
    # Thử extract bảng cho trước
    points = _extract_table_points(content)

    if not points:
        # Không có bảng → tự tạo từ hàm số + range x
        expr_str, degree = _parse_single_function(content)
        x_range = _extract_x_range(content)
        x_vals  = list(range(int(x_range[0]), int(x_range[1])+1))
        x_sym   = symbols("x")
        expr    = _parse_expr(expr_str, x_sym)
        points  = [(xv, round(float(expr.subs(x_sym, xv).evalf()), 4)) for xv in x_vals]
        title   = f"Bảng giá trị y = {expr}"
    else:
        title = "Đồ thị từ bảng giá trị"

    xs = [p[0] for p in points]
    ys = [p[1] for p in points]

    # Build bảng trong steps
    x_row = "  ".join(f"{v:>6.4g}" for v in xs)
    y_row = "  ".join(f"{v:>6.4g}" for v in ys)
    steps = [
        f"{title}",
        f"Bảng giá trị:",
        f"   x │ {x_row}",
        f"   y │ {y_row}",
        "Vẽ đồ thị: Nối các điểm theo thứ tự",
        f"✅ Đồ thị: {len(points)} điểm",
    ]

    fig, ax = _base_axes(title)
    ax.plot(xs, ys, color=_C[0], lw=2, marker="o", markersize=7,
            markerfacecolor="white", markeredgewidth=2,
            markeredgecolor=_C[0], label="Các điểm", zorder=4)
    for xv, yv in points:
        ax.annotate(f"({xv:.4g}; {yv:.4g})", (xv, yv),
                    xytext=(6, 6), textcoords="offset points", fontsize=8,
                    color=_C[0])
    ax.legend(fontsize=9)

    return {
        "success": True,
        "result":  f"Đồ thị qua {len(points)} điểm: " +
                   ", ".join(f"({x:.4g};{y:.4g})" for x, y in points[:5]) +
                   ("..." if len(points) > 5 else ""),
        "steps":   steps,
        "image":   _to_base64(fig),
        "degree":  "discrete",
        "solver":  "graph_value_table",
        "features": {"points": points},
    }


# ─── Detect helpers ───────────────────────────────────────────────────────────

def _is_two_functions(text: str) -> bool:
    return bool(re.search(r"\b(và|and|,)\b.*y\s*=", text)) and \
           text.count("y") >= 2

def _is_find_coefficients(text: str) -> bool:
    kws = ["tìm a", "tìm b", "tìm hệ số", "đi qua", "biết đồ thị"]
    return any(k in text for k in kws)

def _is_value_table(text: str) -> bool:
    kws = ["bảng giá trị", "lập bảng", "x từ", "x=", "x :"]
    return any(k in text for k in kws)

def _is_simple_quadratic(expr_str: str) -> bool:
    """y = ax² (không có bx và c)"""
    norm = expr_str.replace(" ", "")
    return bool(re.match(r"^-?\d*\.?\d*\*?x\*\*2$", norm))


# ─── Parse helpers ─────────────────────────────────────────────────────────────

def _parse_single_function(content: str) -> tuple[str, int]:
    text = content.strip().lower()
    text = re.sub(r"^[yf]\s*(?:\(x\))?\s*=\s*", "", text).strip()
    text = re.sub(r"(vẽ đồ thị|đồ thị hàm|draw|plot)\s*", "", text).strip()
    text = text.replace("^", "**").replace("×","*").replace("÷","/")
    text = text.replace("x²","x**2").replace("x³","x**3")
    text = re.sub(r"(\d)(x)", r"\1*\2", text)
    degree = (3 if re.search(r"x\*\*3|x³", text)
              else 2 if re.search(r"x\*\*2|x²", text)
              else 1 if re.search(r"[a-z]", text) else 0)
    return text, degree

def _parse_expr(expr_str: str, x_sym):
    trans = standard_transformations + (implicit_multiplication_application,)
    return parse_expr(expr_str, transformations=trans, local_dict={"x": x_sym})

def _get_leading_coeff(expr_str: str) -> float:
    match = re.match(r"^(-?\d*\.?\d*)\*?x", expr_str)
    if match:
        val = match.group(1)
        return float(val) if val not in ("", "-") else (-1 if val == "-" else 1)
    return 1

def _extract_two_functions(content: str) -> list[str]:
    """Tách 2 hàm số từ "y=... và y=..." """
    text = content.lower()
    # Tìm tất cả "y = ..."
    parts = re.split(r"\b(và|and|,)\b", text)
    funcs = []
    for p in parts:
        p = p.strip()
        m = re.search(r"y\s*=\s*(.+)", p)
        if m:
            raw = m.group(1).strip()
            raw = raw.replace("^","**").replace("×","*")
            raw = raw.replace("x²","x**2")
            raw = re.sub(r"(\d)(x)", r"\1*\2", raw)
            funcs.append(raw)
    return funcs[:2]

def _extract_points(content: str) -> list[tuple]:
    """Trích tọa độ điểm từ chuỗi: (1;3), (2,5), (-1; 4)"""
    matches = re.findall(r"\(\s*(-?\d+\.?\d*)\s*[;,]\s*(-?\d+\.?\d*)\s*\)", content)
    return [(float(x), float(y)) for x, y in matches]

def _extract_table_points(content: str) -> list[tuple]:
    """Trích bảng x=..., y=... """
    xm = re.search(r"x\s*[=:]\s*([-\d\s,]+)", content, re.IGNORECASE)
    ym = re.search(r"y\s*[=:]\s*([-\d\s,\.]+)", content, re.IGNORECASE)
    if xm and ym:
        xs = [float(v) for v in re.findall(r"-?\d+\.?\d*", xm.group(1))]
        ys = [float(v) for v in re.findall(r"-?\d+\.?\d*", ym.group(1))]
        if len(xs) == len(ys) and len(xs) >= 2:
            return list(zip(xs, ys))
    return []

def _extract_x_range(content: str) -> tuple[float, float]:
    m = re.search(r"x\s+từ\s+(-?\d+)\s+đến\s+(-?\d+)", content, re.IGNORECASE)
    if m:
        return float(m.group(1)), float(m.group(2))
    return -3.0, 3.0


# ─── Plot helpers ──────────────────────────────────────────────────────────────

_C = [
    "#5B5FEF",  # primary (giống Flutter AppColors.primary)
    "#FF5C7A",  # đỏ mềm hơn (giao điểm / highlight)
    "#F59E0B",  # warning (điểm quan trọng)
    "#22C55E",  # success (kết quả)
    "#7C3AED"   # tím phụ (accent AI)
]

def _base_axes(title: str):
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.set_facecolor("#FAFAFA")
    fig.patch.set_facecolor("white")
    ax.axhline(0, color="#1E1F4B", lw=1.2, zorder=1)
    ax.axvline(0, color="#1E1F4B", lw=1.2, zorder=1)
    ax.grid(True, alpha=0.2, linestyle="--")
    ax.set_xlabel("x", fontsize=12, labelpad=6)
    ax.set_ylabel("y", fontsize=12, labelpad=6, rotation=0)
    ax.set_title(title, fontsize=13, fontweight="bold", pad=12)
    plt.tight_layout()
    return fig, ax

def _mark(ax, x, y, label, color, marker="o", size=8):
    ax.plot(x, y, marker=marker, markersize=size, color=color,
            zorder=5, markeredgecolor="white", markeredgewidth=1.5)
    if label:
        ax.annotate(label, (x, y), xytext=(8, 8),
                    textcoords="offset points", fontsize=9, color=color,
                    bbox=dict(boxstyle="round,pad=0.2", fc="white",
                              alpha=0.85, ec=color))

def _to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=130, bbox_inches="tight",
                facecolor="white")
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode("utf-8")

def _decode_and_replot_linear(a, b, given_points) -> plt.Figure:
    """Vẽ lại đường thẳng + highlight các điểm đã cho"""
    xs_pt = [p[0] for p in given_points]
    cx = sum(xs_pt) / len(xs_pt)
    x_vals = np.linspace(cx - 6, cx + 6, 400)
    y_vals = a * x_vals + b
    fig, ax = _base_axes(f"y = {a:.4g}x + {b:.4g}")
    ax.plot(x_vals, y_vals, color=_C[0], lw=2.5,
            label=f"y = {a:.4g}x + {b:.4g}", zorder=3)
    for xp, yp in given_points:
        _mark(ax, xp, yp, f"({xp}; {yp})", _C[1])
    ax.legend(fontsize=10)
    return fig