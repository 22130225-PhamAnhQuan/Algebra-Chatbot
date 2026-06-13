from sympy import sympify, expand

class IdentitySolver:
    def solve(self, content: str):
        steps = []
        clean_content = content.replace("^", "**")
        expr = sympify(clean_content, evaluate=False)

        steps.append(f"\\text{{Khai triển hằng đẳng thức: }} {content}")

        expanded = expand(expr)

        if expanded != expr:
            steps.append(f"\\text{{- Áp dụng hằng đẳng thức đáng nhớ, ta có:}}")
            steps.append(f"= {expanded}")
        else:
             steps.append(f"\\text{{Biểu thức không ở dạng hằng đẳng thức thu gọn.}}")

        return {
            "result": f"{expanded}",
            "latex": f"{expanded}",
            "steps_latex": steps
        }