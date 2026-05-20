# app/services/solver/polynomial_solver.py
#
# Xử lý đa thức và phân thức đại số:
#   Phân tích nhân tử:  x² + 5x + 6  →  (x+2)(x+3)
#   Rút gọn phân thức: (x²-4)/(x-2)  →  x+2
#   Nhân/chia đa thức
#   Tính giá trị biểu thức tại x = k
#
import re
from sympy import (
    symbols, factor, expand, simplify,
    cancel, apart, Symbol, Poly,
    div as poly_div,
)
from sympy.parsing.sympy_parser import (
    parse_expr, standard_transformations,
    implicit_multiplication_application,
)


def factor_polynomial(content: str) -> dict:
    """Phân tích nhân tử: x^2 + 5x + 6 → (x+2)(x+3)"""
    try:
        norm = _normalize(content)
        vars_found = set(re.findall(r"[a-df-z]", norm))
        var = sorted(vars_found)[0] if vars_found else "x"
        x = symbols(var)

        trans = standard_transformations + (implicit_multiplication_application,)
        expr = parse_expr(norm, transformations=trans, local_dict={var: x})

        factored  = factor(expr)
        expanded  = expand(expr)

        steps = [
            f"📌 **Biểu thức:** {content}",
            f"📌 **Bước 1:** Dạng khai triển: `{expanded}`",
            f"📌 **Bước 2:** Tìm các nhân tử chung và áp dụng hằng đẳng thức",
            f"📌 **Bước 3:** Kiểm tra: `{factored}` = `{expand(factored)}`  ✓"
            if expand(factored) == expanded else
            f"📌 **Bước 3:** Phân tích",
            f"✅ **Kết quả:** `{factored}`",
        ]

        return {
            "result":   str(factored),
            "expanded": str(expanded),
            "steps":    steps,
        }

    except Exception as e:
        raise ValueError(f"Không thể phân tích nhân tử: {e}")


def simplify_fraction(content: str) -> dict:
    """Rút gọn phân thức đại số: (x²-4)/(x-2) → x+2"""
    try:
        norm = _normalize(content)
        vars_found = set(re.findall(r"[a-df-z]", norm))
        var = sorted(vars_found)[0] if vars_found else "x"
        x = symbols(var)

        trans = standard_transformations + (implicit_multiplication_application,)
        expr = parse_expr(norm, transformations=trans, local_dict={var: x})

        # cancel() tự động rút gọn tử và mẫu chung
        simplified = cancel(expr)
        factored   = factor(expr)

        steps = [
            f"📌 **Phân thức:** {content}",
            f"📌 **Bước 1:** Phân tích tử và mẫu thành nhân tử",
            f"   = `{factored}`",
            f"📌 **Bước 2:** Rút gọn nhân tử chung",
            f"📌 **Bước 3:** Lưu ý điều kiện xác định ({var} ≠ giá trị làm mẫu = 0)",
            f"✅ **Kết quả:** `{simplified}`",
        ]

        return {
            "result":     str(simplified),
            "factored":   str(factored),
            "steps":      steps,
            "variable":   var,
        }

    except Exception as e:
        raise ValueError(f"Không thể rút gọn phân thức: {e}")


def expand_polynomial(content: str) -> dict:
    """Khai triển đa thức: (x+2)(x+3) → x²+5x+6"""
    try:
        norm = _normalize(content)
        vars_found = set(re.findall(r"[a-df-z]", norm))
        var = sorted(vars_found)[0] if vars_found else "x"
        x = symbols(var)

        trans = standard_transformations + (implicit_multiplication_application,)
        expr = parse_expr(norm, transformations=trans, local_dict={var: x})

        expanded = expand(expr)

        steps = [
            f"📌 **Biểu thức:** {content}",
            f"📌 **Bước 1:** Áp dụng phân phối / hằng đẳng thức",
            f"📌 **Bước 2:** Thu gọn các hạng tử đồng dạng",
            f"✅ **Kết quả:** `{expanded}`",
        ]

        return {"result": str(expanded), "steps": steps}

    except Exception as e:
        raise ValueError(f"Không thể khai triển: {e}")


def evaluate_expression(content: str) -> dict:
    """
    Tính giá trị biểu thức tại giá trị cho trước.
    Ví dụ: "x^2 + 2x + 1 tại x=3"  hoặc  "x^2+2x+1, x=3"
    """
    try:
        # Tách biểu thức và giá trị
        expr_str, subs = _parse_evaluate(content)
        norm = _normalize(expr_str)

        var_dict = {name: symbols(name) for name in subs}
        trans = standard_transformations + (implicit_multiplication_application,)
        expr = parse_expr(norm, transformations=trans, local_dict=var_dict)

        result_sym = expr.subs(list(subs.items()))
        result_num = float(result_sym.evalf())

        subs_str = ", ".join(f"{k}={v}" for k, v in subs.items())
        steps = [
            f"📌 **Biểu thức:** {expr_str}",
            f"📌 **Cho:** {subs_str}",
            f"📌 **Bước 1:** Thay giá trị vào biểu thức",
            f"   = `{expr.subs(list(subs.items()))}`",
            f"📌 **Bước 2:** Tính toán",
            f"✅ **Kết quả:** `{result_sym}` = **{result_num}**",
        ]

        return {
            "result":  str(result_sym),
            "numeric": result_num,
            "steps":   steps,
        }

    except Exception as e:
        raise ValueError(f"Không thể tính giá trị biểu thức: {e}")


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _normalize(text: str) -> str:
    text = text.strip().lower()
    text = text.replace("^", "**").replace("×", "*").replace("÷", "/")
    text = re.sub(r"(\d)([a-z])", r"\1*\2", text)
    return text


def _parse_evaluate(content: str) -> tuple[str, dict]:
    """Tách "x^2+2x+1 tại x=3" → ("x^2+2x+1", {"x": 3})"""
    subs = {}

    # Tìm pattern "tại x=3" hoặc "x=3" ở cuối
    patterns = [
        r"(?:tại|với|when|at|,)\s*([a-z])\s*=\s*(-?[\d.]+)",
        r"([a-z])\s*=\s*(-?[\d.]+)\s*$",
    ]

    expr_str = content
    for pat in patterns:
        matches = re.findall(pat, content, re.IGNORECASE)
        for var, val in matches:
            subs[symbols(var)] = float(val)
            expr_str = re.sub(pat, "", expr_str, flags=re.IGNORECASE).strip(" ,")

    if not subs:
        raise ValueError(
            "Không tìm thấy giá trị thay vào. "
            "Ví dụ: 'x^2 + 2x tại x=3'"
        )

    return expr_str.strip(), subs
