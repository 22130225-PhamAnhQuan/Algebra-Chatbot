from sympy import symbols, Eq, sympify, solve, latex, simplify


class SystemSolver:
    def solve(self, content: str):
        steps_latex = []
        x, y = symbols("x y")

        clean_content = content.replace(r"\begin{cases}", "").replace(r"\end{cases}", "").replace(r"\\", ";").replace(
            "\n", ";")
        eqs = [e.strip() for e in clean_content.split(";") if e.strip()]

        if len(eqs) != 2:
            return {"result": "Lỗi",
                    "steps_latex": ["\\text{Vui lòng nhập hệ gồm đúng 2 phương trình, ngăn cách bằng dấu ;}"]}

        eq1, eq2 = eqs[0], eqs[1]
        l1, r1 = eq1.split("=")
        l2, r2 = eq2.split("=")

        expr1 = Eq(sympify(l1), sympify(r1))
        expr2 = Eq(sympify(l2), sympify(r2))

        system_latex = f"\\left\\{{\\begin{{matrix}} {latex(expr1)} \\\\ {latex(expr2)} \\end{{matrix}}\\right."
        steps_latex.append(f"\\text{{Giải hệ phương trình: }} {system_latex}")

        result = solve((expr1, expr2), (x, y), dict=True)

        if len(result) == 0:
            steps_latex.append(r"\Rightarrow \text{Hệ phương trình vô nghiệm}")
            return {"result": "Vô nghiệm", "latex": r"\emptyset", "steps_latex": steps_latex}

        sol = result[0]
        x_val = simplify(sol[x])
        y_val = simplify(sol[y])

        steps_latex.append("\\text{Áp dụng phương pháp đại số (thế / cộng đại số), ta tìm được:}")
        steps_latex.append(
            f"\\Leftrightarrow \\left\\{{\\begin{{matrix}} x = {latex(x_val)} \\\\ y = {latex(y_val)} \\end{{matrix}}\\right.")

        result_str = f"(x; y) = ({x_val}; {y_val})"
        steps_latex.append(f"\\text{{Vậy hệ có nghiệm duy nhất: }} {result_str}")

        return {
            "result": f"S = {{({x_val}; {y_val})}}",
            "latex": f"({latex(x_val)}; {latex(y_val)})",
            "steps_latex": steps_latex
        }