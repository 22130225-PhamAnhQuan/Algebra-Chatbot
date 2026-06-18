from sympy import Eq, solve, latex, simplify, together, fraction, Poly
from sympy.calculus.singularities import singularities
from app.services.solver.parser import parse_equation


class RationalEquationSolver:
    def solve(self, content: str):
        TEX_DKXD = "\\text{Điều kiện xác định: }"
        TEX_QUY_DONG = "\\text{Quy đồng mẫu thức hai vế, ta được: }"
        TEX_KHU_MAU = "\\Rightarrow \\text{Khử mẫu, ta có phương trình: }"
        TEX_THOA_MAN = "\\text{ (Thỏa mãn ĐKXĐ)}"
        TEX_LOAI = "\\text{ (Loại)}"

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
                dkxd_str = f"{var_name} \\neq " + f" \\text{'và'} {var_name} \\neq ".join(points)
                steps_latex.append(f"{TEX_DKXD} {dkxd_str}")

            # 2. QUY ĐỒNG MẪU THỨC
            combined_expr = together(expr)
            numer, denom = fraction(combined_expr)
            numer = simplify(numer)

            steps_latex.append(TEX_QUY_DONG)
            steps_latex.append(f"\\Leftrightarrow {latex(Eq(combined_expr, 0))}")

            # 3. KHỬ MẪU
            steps_latex.append(TEX_KHU_MAU)
            steps_latex.append(f"{latex(Eq(numer, 0))}")

            # 4. GIẢI PHƯƠNG TRÌNH
            poly = Poly(numer, main_var)

            if poly.degree() == 2:
                a = poly.coeff_monomial(main_var ** 2)
                b = poly.coeff_monomial(main_var)
                c = poly.coeff_monomial(1)

                delta = simplify(b ** 2 - 4 * a * c)
                steps_latex.append(
                    f"\\text{{Xét phương trình tử số, ta có: }} a={latex(a)}; b={latex(b)}; c={latex(c)}")
                steps_latex.append(
                    f"\\Delta = b^2 - 4ac = ({latex(b)})^2 - 4 \\cdot ({latex(a)}) \\cdot ({latex(c)}) = {latex(delta)}")

                if delta < 0:
                    steps_latex.append(r"\text{Vì } \Delta < 0 \text{ nên phương trình tử số vô nghiệm.}")
                elif delta == 0:
                    steps_latex.append(r"\text{Vì } \Delta = 0 \text{ nên phương trình có nghiệm kép:}")
                else:
                    steps_latex.append(r"\text{Vì } \Delta > 0 \text{ nên phương trình có 2 nghiệm phân biệt:}")

            raw_solutions = solve(Eq(numer, 0), main_var)

            if not raw_solutions:
                if poly.degree() != 2:  # Nếu bậc 2 đã in câu vô nghiệm ở trên rồi thì không in lại
                    steps_latex.append("\\Leftrightarrow \\text{Phương trình tử số vô nghiệm}")
                return {"result": "Vô nghiệm", "latex": "\\emptyset", "steps_latex": steps_latex, "type": "rational"}

            # 5. ĐỐI CHIẾU NGHIỆM
            final_solutions = []
            for i, sol in enumerate(raw_solutions):
                sol_name = f"{var_name}_{{{i + 1}}}" if len(raw_solutions) > 1 else var_name
                if invalid_points.contains(sol):
                    steps_latex.append(f"\\Rightarrow {sol_name} = {latex(sol)} {TEX_LOAI}")
                else:
                    steps_latex.append(f"\\Rightarrow {sol_name} = {latex(sol)} {TEX_THOA_MAN}")
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