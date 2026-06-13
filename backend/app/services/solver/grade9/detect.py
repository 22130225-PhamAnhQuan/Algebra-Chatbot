def detect_grade9_type(content: str) -> str:
    text = content.lower().strip()

    if "đồ thị" in text or "parabol" in text or "y=" in text or "y =" in text:
        return "graph"

    if "\\begin{cases}" in text or ("=" in text and ";" in text):
        return "system"

    if any(op in text for op in [">", "<", "\\ge", "\\le"]):
        return "inequality"


    return "quadratic"