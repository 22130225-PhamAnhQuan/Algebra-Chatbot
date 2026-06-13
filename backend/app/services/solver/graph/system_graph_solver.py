from sympy import symbols, Eq, sympify, solve, latex, simplify


class SystemGraphSolver:
    def solve(self, content: str):
        x = symbols("x")
        steps_latex = []

        # Bóc tách 2 phương trình y = ...
        eqs = content.lower().replace(" ", "").split(";")
        if len(eqs) != 2:
            return {"result": "Lỗi", "steps_latex": ["\\text{Nhập 2 hàm số ngăn cách bởi dấu chấm phẩy (;)}"]}

        expr1 = sympify(eqs[0].replace("y=", "").replace("^", "**"))
        expr2 = sympify(eqs[1].replace("y=", "").replace("^", "**"))

        steps_latex.append(f"\\text{{Xét phương trình hoành độ giao điểm của hai đồ thị:}}")
        steps_latex.append(f"{latex(expr1)} = {latex(expr2)}")

        # Chuyển vế giải
        eq = Eq(expr1, expr2)
        solutions = solve(eq, x)

        if not solutions:
            steps_latex.append("\\Rightarrow \\text{Phương trình vô nghiệm.}")
            steps_latex.append("\\text{Kết luận: Hai đồ thị không cắt nhau (hoặc song song).}")
            return {"result": "Không cắt nhau", "latex": r"\emptyset", "steps_latex": steps_latex}

        points = []
        for sol in solutions:
            y_val = simplify(expr1.subs(x, sol))
            points.append(f"({latex(sol)}; {latex(y_val)})")

            steps_latex.append(f"\\text{{+ Với }} x = {latex(sol)} \\Rightarrow y = {latex(y_val)}")

        result_str = " \\text{ và } ".join(points)
        steps_latex.append(f"\\text{{Vậy tọa độ giao điểm của hai đồ thị là: }} {result_str}")

        return {
            "result": "Đã tìm được giao điểm",
            "latex": result_str,
            "steps_latex": steps_latex
        }