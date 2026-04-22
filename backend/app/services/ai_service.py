import sympy as sp
from sympy import symbols, Eq, solve
import re

x, y = symbols('x y')


# =========================
# DETECT TYPE
# =========================
def detect_type(content: str):
    content = content.replace(" ", "")

    if ";" in content or "\n" in content:
        return "system"

    if "=" in content:
        if "x**2" in content or "x^2" in content:
            return "quadratic"
        return "linear"

    return "expression"


# =========================
# LINEAR
# =========================
def solve_linear(eq_str):
    left, right = eq_str.split("=")
    eq = Eq(sp.sympify(left), sp.sympify(right))
    result = solve(eq, x)

    return {
        "result": f"x = {result[0]}",
        "steps": f"Giải phương trình bậc 1: {eq} → x = {result[0]}",
        "latex": sp.latex(result[0])
    }


# =========================
# QUADRATIC
# =========================
def solve_quadratic(eq_str):
    eq_str = eq_str.replace("^", "**")
    left, right = eq_str.split("=")
    eq = Eq(sp.sympify(left), sp.sympify(right))

    result = solve(eq, x)

    return {
        "result": f"x = {result}",
        "steps": f"Giải PT bậc 2: {eq} → nghiệm = {result}",
        "latex": ", ".join([sp.latex(r) for r in result])
    }


# =========================
# SYSTEM
# =========================
def solve_system(content):
    lines = content.split("\n")
    eqs = []

    for line in lines:
        if "=" in line:
            left, right = line.split("=")
            eqs.append(Eq(sp.sympify(left), sp.sympify(right)))

    result = solve(eqs, (x, y))

    return {
        "result": str(result),
        "steps": f"Giải hệ phương trình → {result}",
        "latex": str(result)
    }


# =========================
# EXPRESSION
# =========================
def simplify_expression(content):
    expr = sp.sympify(content)
    simplified = sp.simplify(expr)

    return {
        "result": str(simplified),
        "steps": f"Rút gọn biểu thức → {simplified}",
        "latex": sp.latex(simplified)
    }


# =========================
# MAIN FUNCTION
# =========================
def solve_math_problem(content: str):

    try:
        math_type = detect_type(content)

        if math_type == "linear":
            return solve_linear(content)

        elif math_type == "quadratic":
            return solve_quadratic(content)

        elif math_type == "system":
            return solve_system(content)

        else:
            return simplify_expression(content)

    except Exception as e:
        return {
            "result": "Không giải được",
            "steps": f"Lỗi xử lý: {str(e)}",
            "latex": ""
        }