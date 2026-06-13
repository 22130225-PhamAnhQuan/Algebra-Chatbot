from sympy import symbols, expand, simplify, solve, latex, S
from sympy.parsing.sympy_parser import parse_expr

class InequalitySolver:
    def solve(self, content: str):
        x = symbols("x")
        steps_latex = []

        if "<=" in content:
            lhs_str, rhs_str, operator = content.split("<=")[0], content.split("<=")[1], "\\le"
        elif ">=" in content:
            lhs_str, rhs_str, operator = content.split(">=")[0], content.split(">=")[1], "\\ge"
        elif "<" in content:
            lhs_str, rhs_str, operator = content.split("<")[0], content.split("<")[1], "<"
        else:
            lhs_str, rhs_str, operator = content.split(">")[0], content.split(">")[1], ">"

        lhs = parse_expr(lhs_str)
        rhs = parse_expr(rhs_str)

        steps_latex.append(f"\\text{{Giải bất phương trình: }} {latex(lhs)} {operator} {latex(rhs)}")

        lhs_expand = expand(lhs)
        rhs_expand = expand(rhs)
        expr_zero = simplify(lhs_expand - rhs_expand)

        steps_latex.append(f"\\Leftrightarrow {latex(expr_zero)} {operator} 0")

        poly = expr_zero.as_poly(x)

        if poly and poly.degree() == 1:
            a, b = poly.all_coeffs()
            steps_latex.append(f"\\Leftrightarrow {latex(a*x)} {operator} {latex(-b)}")

            if a < 0:
                rev_op = {"\\le": "\\ge", "\\ge": "\\le", "<": ">", ">": "<"}[operator]
                steps_latex.append("\\text{(Chia hai vế cho số âm, bất đẳng thức đổi chiều)}")
                ans = simplify((-b) / a)
                steps_latex.append(f"\\Leftrightarrow x {rev_op} {latex(ans)}")
                result_latex = f"x {rev_op} {latex(ans)}"
            else:
                ans = simplify((-b) / a)
                steps_latex.append(f"\\Leftrightarrow x {operator} {latex(ans)}")
                result_latex = f"x {operator} {latex(ans)}"
        else:
            sol = solve(expr_zero > 0 if operator == ">" else expr_zero < 0 if operator == "<" else expr_zero >= 0 if operator == "\\ge" else expr_zero <= 0, x)
            result_latex = latex(sol)
            steps_latex.append(f"\\Leftrightarrow {result_latex}")

        steps_latex.append(f"\\text{{Vậy tập nghiệm của bất phương trình là: }} S = \\{{{x} \\mid {result_latex}\\}}")

        return {
            "result": f"S = {{x | {result_latex.replace('$', '')}}}",
            "latex": f"S = \\{{{x} \\mid {result_latex}\\}}",
            "steps_latex": steps_latex
        }