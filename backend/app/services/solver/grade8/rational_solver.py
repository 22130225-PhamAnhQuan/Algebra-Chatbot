from sympy import Eq, solve, latex, simplify, together, fraction
from sympy.calculus.singularities import singularities
from app.services.solver.parser import parse_equation


class RationalEquationSolver:
    def solve(self, content: str):
        TEX_DKXD = "\\text{Điều kiện xác định (ĐKXĐ): }"
        TEX_QUY_DONG = "\\text{Quy đồng mẫu thức hai vế, ta được: }"
        TEX_KHU_MAU = "\\Rightarrow \\text{Khử mẫu, ta có phương trình: }"
        TEX_THOA_MAN = "\\text{ (Thỏa mãn ĐKXĐ)}"
        TEX_LOAI = "\\text{ (Không thỏa mãn ĐKXĐ - Loại)}"

        try:
            main_var, lhs, rhs, var_name = parse_equation(content)
            expr = lhs - rhs

            steps_latex = []
            steps_latex.append(f"{latex(Eq(lhs, rhs))}")

            # 1. TÌM ĐKXĐ
            invalid_points = singularities(expr, main_var)

            if invalid_points.is_empty:
                steps_latex.append(f"{TEX_DKXD} {var_name} \\in \\mathbb{{R}}")
            else:
                points = [latex(p) for p in invalid_points]
                dkxd_str = f"{var_name} \\neq " + f" \\text{ 'và' } {var_name} \\neq ".join(points)
                steps_latex.append(f"{TEX_DKXD} {dkxd_str}")

            # 2. QUY ĐỒNG MẪU THỨC
            # Hàm 'together' sẽ tự động tìm Mẫu thức chung và quy đồng
            combined_expr = together(expr)

            # Tách tử số và mẫu số sau khi quy đồng
            numer, denom = fraction(combined_expr)
            numer = simplify(numer)  # Rút gọn tử số cho đẹp

            steps_latex.append(TEX_QUY_DONG)
            steps_latex.append(f"\\Leftrightarrow {latex(Eq(combined_expr, 0))}")

            # 3. KHỬ MẪU
            steps_latex.append(TEX_KHU_MAU)
            steps_latex.append(f"{latex(Eq(numer, 0))}")

            # 4. GIẢI PHƯƠNG TRÌNH TỬ SỐ
            raw_solutions = solve(Eq(numer, 0), main_var)

            if not raw_solutions:
                steps_latex.append("\\Leftrightarrow \\text{Phương trình tử số vô nghiệm}")
                return {"result": "Vô nghiệm", "latex": "\\emptyset", "steps_latex": steps_latex, "type": "rational"}

            # 5. ĐỐI CHIẾU NGHIỆM
            final_solutions = []
            for sol in raw_solutions:
                if invalid_points.contains(sol):
                    steps_latex.append(f"\\Leftrightarrow {var_name} = {latex(sol)} {TEX_LOAI}")
                else:
                    steps_latex.append(f"\\Leftrightarrow {var_name} = {latex(sol)} {TEX_THOA_MAN}")
                    final_solutions.append(sol)

            # 6. KẾT LUẬN
            if not final_solutions:
                steps_latex.append("\\text{Vậy phương trình đã cho vô nghiệm.}")
                result_latex = "\\emptyset"
                result_text = "Vô nghiệm"
            else:
                sols_latex = "; ".join([latex(s) for s in final_solutions])
                steps_latex.append(f"\\text{{Vậy tập nghiệm của phương trình là: }} S = \\{{{sols_latex}\\}}")
                result_latex = f"S = \\{{{sols_latex}\\}}"
                result_text = f"S = {{{sols_latex}}}"

            return {
                "result": result_text,
                "latex": result_latex,
                "steps_latex": steps_latex,
                "type": "rational"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi cú pháp}",
                "steps_latex": [f"\\text{{Lỗi xử lý: {str(e)}}}"]
            }