from sympy import symbols, Eq, solve, latex, simplify
from app.services.solver.parser import parse_equation


class SystemSolver:
    def solve(self, content: str):
        TEX_HE = "\\text{Giải hệ phương trình: }"
        TEX_NGHIEM = "\\text{Vậy hệ có nghiệm duy nhất: }"

        try:
            steps_latex = []

            eqs = [e.strip() for e in content.replace('\n', ';').split(';') if e.strip()]

            if len(eqs) != 2:
                return {"result": "Lỗi",
                        "steps_latex": [r"\text{Vui lòng nhập hệ gồm 2 phương trình (cách nhau bởi dấu ;)}"]}

            # Chuyển đổi sang biểu thức SymPy
            equations = []
            for eq_str in eqs:
                _, lhs, rhs, _ = parse_equation(eq_str)
                equations.append(Eq(lhs, rhs))

            eq1, eq2 = equations
            
            system_latex = f"\\left\\{{\\begin{{matrix}} {latex(eq1)} \\\\ {latex(eq2)} \\end{{matrix}}\\right."
            steps_latex.append(f"{TEX_HE} {system_latex}")

            # Lấy danh sách các biến tự do xuất hiện trong hệ phương trình
            all_symbols = eq1.free_symbols.union(eq2.free_symbols)
            vars_list = sorted(list(all_symbols), key=lambda s: s.name)

            if len(vars_list) == 1:
                var1 = vars_list[0]
                result = solve((eq1, eq2), (var1,), dict=True)
                if not result:
                    steps_latex.append(r"\Rightarrow \text{Hệ phương trình vô nghiệm}")
                    return {"result": "Vô nghiệm", "latex": r"\emptyset", "steps_latex": steps_latex, "type": "system_equation"}
                sol = result[0]
                v1_val = simplify(sol.get(var1, var1))
                steps_latex.append(r"\text{Biến đổi phương trình, ta tìm được:}")
                steps_latex.append(f"\\Leftrightarrow {var1.name} = {latex(v1_val)}")
                steps_latex.append(f"{TEX_NGHIEM} {var1.name} = {latex(v1_val)}")
                return {
                    "result": f"{var1.name} = {v1_val}",
                    "latex": f"{var1.name} = {latex(v1_val)}",
                    "steps_latex": steps_latex,
                    "type": "system_equation"
                }

            if len(vars_list) == 2:
                var1, var2 = vars_list
            else:
                var1, var2 = symbols("x y")

            # Giải hệ
            result = solve((eq1, eq2), (var1, var2), dict=True)

            if not result:
                steps_latex.append(r"\Rightarrow \text{Hệ phương trình vô nghiệm}")
                return {"result": "Vô nghiệm", "latex": r"\emptyset", "steps_latex": steps_latex,
                        "type": "system_equation"}

            sol = result[0]
            v1_val = simplify(sol.get(var1, var1))
            v2_val = simplify(sol.get(var2, var2))

            steps_latex.append(r"\text{Áp dụng phương pháp giải hệ, ta tìm được:}")
            steps_latex.append(
                f"\\Leftrightarrow \\left\\{{\\begin{{matrix}} {var1.name} = {latex(v1_val)} \\\\ {var2.name} = {latex(v2_val)} \\end{{matrix}}\\right.")

            steps_latex.append(f"{TEX_NGHIEM} ({var1.name}; {var2.name}) = ({latex(v1_val)}; {latex(v2_val)})")

            return {
                "result": f"{var1.name} = {v1_val}, {var2.name} = {v2_val}",
                "latex": f"({var1.name}; {var2.name}) = ({latex(v1_val)}; {latex(v2_val)})",
                "steps_latex": steps_latex,
                "type": "system_equation"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }