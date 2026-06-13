from sympy import symbols, sympify, solve, Eq


class ProportionSolver:
    def solve(self, content: str):
        steps = []
        x = symbols("x")

        try:
            lhs, rhs = content.split("=")
            left_expr = sympify(lhs.replace(":", "/"))
            right_expr = sympify(rhs.replace(":", "/"))
        except ValueError:
            return {"result": "Lỗi định dạng", "steps_latex": ["\\text{Vui lòng nhập định dạng: a/b = c/d}"]}

        eq = Eq(left_expr, right_expr)
        steps.append(f"\\text{{Tìm x trong tỉ lệ thức: }} {left_expr} = {right_expr}")

        if left_expr.is_Mul or left_expr.is_Pow or right_expr.is_Mul:
            pass
        else:
            steps.append(f"\\text{{Áp dụng tính chất tỉ lệ thức (tích chéo bằng nhau):}}")

        solution = solve(eq, x)

        if not solution:
            steps.append("\\text{Phương trình vô nghiệm.}")
            return {"result": "Vô nghiệm", "latex": "\\emptyset", "steps_latex": steps}

        ans = solution[0]
        steps.append(f"\\Rightarrow x = {ans}")

        return {
            "result": f"x = {ans}",
            "latex": f"x = {ans}",
            "steps_latex": steps
        }