from sympy import simplify, Poly
from app.services.solver.parser import parse_equation
import logging

logger = logging.getLogger(__name__)


def detect_grade8_type(content: str):
    text = content.lower()

    if "đồ thị" in text or "vẽ" in text or "graph" in text:
        return "graph"
    if "phân tích" in text or "nhân tử" in text:
        return "factor"
    if "hằng đẳng thức" in text or "khai triển" in text:
        return "identity"

    if any(op in text for op in ["<=", ">=", "<", ">"]):
        return "inequality"
    if ";" in text or "\\begin{cases}" in text or "\n" in text:
        return "system"

    try:
        main_var, lhs, rhs, var_name = parse_equation(content)
        expr = simplify(lhs - rhs)

        # Kiểm tra phương trình chứa ẩn ở mẫu
        numer, denom = expr.as_numer_denom()
        if denom.has(main_var):
            return "rational"

        # Đo bậc của phương trình
        poly = Poly(expr, main_var)
        degree = poly.degree()

        if degree == 2:
            return "quadratic"

        if "=" in text or degree == 1:
            return "linear"

    except Exception as e:
        logger.warning(f"Không thể phân tích ngữ nghĩa tự động: {str(e)}")

    return "linear" if "=" in text else "factor"