import re


def detect_grade7_type(content):
    text = content.lower().replace(":", "/")

    if "đồ thị" in text or "y=" in text or "y =" in text:
        return "graph"

    if "tại" in text or "với" in text:
        return "evaluate"
    if "=" in text and "/" in text:
        return "proportion"
    if re.search(r"[a-z]", text):
        return "polynomial"

    return "simplify"