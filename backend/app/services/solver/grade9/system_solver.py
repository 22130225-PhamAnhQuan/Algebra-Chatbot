from sympy import symbols, Eq, sympify, solve, latex, simplify
from app.services.solver.parser import parse_equation


class SystemSolver:
    def solve(self, content: str):
        TEX_HE = "\\text{Giải hệ phương trình: }"
        TEX_NGHIEM = "\\text{Vậy hệ có nghiệm duy nhất: }"

        try:
            steps_latex = []
            x, y = symbols("x y")

            eqs = [e.strip() for e in content.replace('\n', ';').split(';') if e.strip()]

            if len(eqs) != 2:
                return {"result": "Lỗi",
                        "steps_latex": [r"\text{Vui lòng nhập hệ gồm 2 phương trình (cách nhau bởi dấu ;)}"]}

            # Chuyển đổi sang biểu thức SymPy
            equations = []
            for eq_str in eqs:
                # Dùng parse_equation đã chuẩn hóa cho an toàn
                _, lhs, rhs, _ = parse_equation(eq_str)
                equations.append(Eq(lhs, rhs))

            eq1, eq2 = equations
            system_latex = f"\\left\\{{\\begin{{matrix}} {latex(eq1)} \\\\ {latex(eq2)} \\end{{matrix}}\\right."
            steps_latex.append(f"{TEX_HE} {system_latex}")

            # Giải hệ
            result = solve((eq1, eq2), (x, y), dict=True)

            if not result:
                steps_latex.append(r"\Rightarrow \text{Hệ phương trình vô nghiệm}")
                return {"result": "Vô nghiệm", "latex": r"\emptyset", "steps_latex": steps_latex}

            sol = result[0]
            x_val = simplify(sol[x])
            y_val = simplify(sol[y])

            steps_latex.append(r"\text{Áp dụng phương pháp giải hệ, ta tìm được:}")
            steps_latex.append(
                f"\\Leftrightarrow \\left\\{{\\begin{{matrix}} x = {latex(x_val)} \\\\ y = {latex(y_val)} \\end{{matrix}}\\right.")

            steps_latex.append(f"{TEX_NGHIEM} (x; y) = ({latex(x_val)}; {latex(y_val)})")

            return {
                "result": f"x = {x_val}, y = {y_val}",
                "latex": f"(x; y) = ({latex(x_val)}; {latex(y_val)})",
                "steps_latex": steps_latex,
                "type": "system_equation"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }