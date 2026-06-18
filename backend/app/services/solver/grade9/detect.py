from sympy import simplify, Poly
from app.services.solver.parser import parse_equation
import logging

logger = logging.getLogger(__name__)

def detect_grade9_type(content: str) -> str:
    text = content.lower().strip()

    # đồ thị
    if "y=" in text or "f(x)=" in text or any(kw in text for kw in ["đồ thị", "parabol", "vẽ", "graph"]):
        return "graph"

    # hệ phương trình
    if ";" in text or "\\begin{cases}" in text or "\n" in text:
        return "system"

    # bất phương trình
    if any(op in text for op in [">", "<", ">=", "<=", "\\ge", "\\le"]):
        return "inequality"

    try:
        main_var, lhs, rhs, _ = parse_equation(content)
        expr = simplify(lhs - rhs)

        if expr.as_numer_denom()[1].has(main_var):
            return "rational"

        poly = Poly(expr, main_var)
        degree = poly.degree()

        if degree == 2: return "quadratic"
        if degree == 1: return "linear"
        return "unknown"
    except:
        return "quadratic" if ("^2" in text or "²" in text) else "linear"