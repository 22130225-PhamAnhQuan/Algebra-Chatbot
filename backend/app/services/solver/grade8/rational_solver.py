from sympy import simplify, solve, latex, Eq
from sympy.calculus.singularities import singularities
from app.services.solver.parser import parse_equation


class RationalEquationSolver:
    def solve(self, content: str):
        TEX_DKXD = "\\text{Điều kiện xác định (ĐKXĐ): }"
        TEX_KHU_MAU = "\\text{Quy đồng và khử mẫu, ta được: }"
        TEX_THOA_MAN = "\\text{ (Thỏa mãn ĐKXĐ)}"
        TEX_LOAI = "\\text{ (Không thỏa mãn ĐKXĐ - Loại)}"

        try:
            main_var, lhs, rhs, var_name = parse_equation(content)
            expr = lhs - rhs

            steps_latex = []
            steps_latex.append(f"{latex(Eq(lhs, rhs))}")

            # 1. TÌM ĐIỀU KIỆN XÁC ĐỊNH (ĐKXĐ)
            invalid_points = singularities(expr, main_var)

            if invalid_points.is_empty:
                steps_latex.append(f"{TEX_DKXD} {var_name} \\in \\mathbb{{R}}")
            else:
                points = [latex(p) for p in invalid_points]
                dkxd_str = f"{var_name} \\neq " + f" \\text{'và'} {var_name} \\neq ".join(points)
                steps_latex.append(f"{TEX_DKXD} {dkxd_str}")

            # 2. QUY ĐỒNG VÀ KHỬ MẪU
            simplified_expr = simplify(expr)
            numer, denom = simplified_expr.as_numer_denom()

            steps_latex.append(TEX_KHU_MAU)

            steps_latex.append(f"\\Rightarrow {latex(Eq(numer, 0))}")

            # 3. GIẢI PHƯƠNG TRÌNH TỬ SỐ
            raw_solutions = solve(Eq(numer, 0), main_var)

            if not raw_solutions:
                steps_latex.append("\\Rightarrow \\text{Phương trình vô nghiệm}")
                return {"result": "Vô nghiệm", "latex": "\\emptyset", "steps_latex": steps_latex,
                        "type": "rational_equation"}

            # 4. ĐỐI CHIẾU NGHIỆM VỚI ĐKXĐ
            final_solutions = []
            for sol in raw_solutions:
                if invalid_points.contains(sol):
                    steps_latex.append(f"\\Rightarrow {var_name} = {latex(sol)} {TEX_LOAI}")
                else:
                    steps_latex.append(f"\\Rightarrow {var_name} = {latex(sol)} {TEX_THOA_MAN}")
                    final_solutions.append(sol)

            # 5. KẾT LUẬN TẬP NGHIỆM
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
                "type": "rational_equation"
            }

        except Exception as e:
            return {
                "result": "Lỗi",
                "latex": "\\text{Lỗi giải phương trình}",
                "steps_latex": [f"\\text{{Lỗi: {str(e)}}}"]
            }