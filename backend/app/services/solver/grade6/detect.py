def detect_grade6_type(content: str) -> str:
    text = content.lower().strip()

    if "%" in text:
        return "percentage"
    if "ucln" in text or "gcd" in text:
        return "gcd"
    if "bcnn" in text or "lcm" in text:
        return "lcm"

    if "/" in text and any(op in text for op in ["+", "-", "*"]):
        return "fraction"

    if ":" in text:
        return "ratio"
    if "/" in text:
        return "fraction"
    if "^" in text or "**" in text:
        return "exponent"

    return "integer"