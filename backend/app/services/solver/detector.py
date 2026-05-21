import re


def detect_type(content: str):
    text = content.lower().strip()

    # ========================
    # 1. GRAPH DETECTION (ĐÃ NÂNG CẤP)
    # ========================
    # Dùng regex bắt chính xác y=, y =, hoặc f(x)= bất chấp khoảng trắng
    is_graph_eq = bool(re.search(r"\b(y|f\s*\(\s*x\s*\))\s*=", text))

    if is_graph_eq or any(k in text for k in [
        "vẽ đồ thị",
        "đồ thị",
        "plot",
        "graph",
        "giao điểm",
        "hàm số"
    ]):
        return "graph"

    # ========================
    # 2. FRACTION
    # ========================
    if "\\frac" in text:
        return "fraction"

    # ========================
    # 3. QUADRATIC
    # ========================
    if "x^2" in text or "x²" in text or "bậc 2" in text:
        return "quadratic"

    # ========================
    # 4. SYSTEM
    # ========================
    if "\\begin{cases}" in text:
        return "system"

    # ========================
    # 5. INEQUALITY
    # ========================
    if any(op in text for op in [">", "<", "\\geq", "\\leq"]):
        return "inequality"

    # ========================
    # 6. LINEAR
    # ========================
    if "=" in text:
        return "linear"

    return "simplify"