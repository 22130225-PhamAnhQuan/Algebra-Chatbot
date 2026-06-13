from sympy import sympify, expand, collect, Poly, symbols


class PolynomialSimplifySolver:
    def solve(self, content: str):
        steps = []
        x = symbols("x")

        clean_content = content.replace("^", "**")
        expr = sympify(clean_content, evaluate=False)

        steps.append(f"\\text{{Biểu thức đa thức cần xử lý: }} {content}")

        expanded = expand(expr)
        if expanded != expr:
            steps.append(f"\\text{{- Khai triển biểu thức:}}")
            steps.append(f"= {expanded}")

        result = collect(expanded, x)

        try:
            poly = Poly(result, x)
            grouped = []
            for degree in sorted(poly.as_dict().keys(), reverse=True):
                coeff = poly.as_dict()[degree]
                power = degree[0]
                if power == 0:
                    grouped.append(f"{coeff}")
                elif power == 1:
                    grouped.append(f"{coeff}x" if coeff != 1 else "x")
                else:
                    grouped.append(f"{coeff}x^{{{power}}}" if coeff != 1 else f"x^{{{power}}}")

            grouped_text = " + ".join(grouped).replace("+ -", "- ")
            if grouped_text != str(result).replace("**", "^"):
                steps.append(f"\\text{{- Thu gọn và sắp xếp theo lũy thừa giảm dần:}}")
                steps.append(f"= {grouped_text}")
        except Exception:
            pass

        steps.append(f"\\Rightarrow \\text{{Kết quả cuối cùng: }} {result}")

        return {
            "result": f"{result}",
            "latex": f"{result}",
            "steps_latex": steps  # Đồng bộ biến steps_latex
        }