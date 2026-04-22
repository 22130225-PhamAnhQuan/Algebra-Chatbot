def detect_type(content: str):
    content = content.replace(" ", "")

    if ";" in content:
        return "system"

    if "x^2" in content or "x**2" in content:
        return "quadratic"

    if "=" in content:
        return "linear"

    return "unknown"