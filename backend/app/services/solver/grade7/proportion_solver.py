from sympy import Eq, solve, latex
from app.services.solver.parser import parse_equation


class ProportionSolver:
    def solve(self, content: str):
        TEX_TIM_X = "\\text{Tìm x trong tỉ lệ thức: }"
        TEX_TICH_CHEO = "\\text{Áp dụng tính chất tỉ lệ thức (tích chéo bằng nhau):}"
        TEX_VO_NGHIEM = "\\text{Phương trình vô nghiệm.}"

        try:
            clean_content = content.replace(":", "/")

            main_var, lhs, rhs, var_name = parse_equation(clean_content)

            steps_latex = []
            steps_latex.append(f"{TEX_TIM_X} {latex(Eq(lhs, rhs))}")
            steps_latex.append(TEX_TICH_CHEO)

            solution = solve(Eq(lhs, rhs), main_var)

            if not solution:
                steps_latex.append(TEX_VO_NGHIEM)
                return {"result": "Vô nghiệm", "latex": "\\emptyset", "steps_latex": steps_latex, "type": "proportion"}

            ans = solution[0]
            steps_latex.append(f"\\Rightarrow {var_name} = {latex(ans)}")

            return {
                "result": f"{var_name} = {ans}",
                "latex": f"{var_name} = {latex(ans)}",
                "steps_latex": steps_latex,
                "type": "proportion"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Vui lòng nhập định dạng: a/b = c/d}",
                "steps_latex": [f"\\text{{Lỗi định dạng: {str(e)}}}"]
            }