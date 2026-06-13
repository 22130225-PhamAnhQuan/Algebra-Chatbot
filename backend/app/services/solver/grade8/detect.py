def detect_grade8_type(content):
    text = content.lower()

    if "đồ thị" in text or "y=" in text or "y =" in text:
        return "graph"

    if "phân tích" in text or "nhân tử" in text:
        return "factor"
    if "hằng đẳng thức" in text or "khai triển" in text:
        return "identity"
    if "=" in text:
        return "linear"

    return "factor"