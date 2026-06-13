
from sympy import *
from sympy.parsing.sympy_parser import (
    parse_expr,
    standard_transformations,
    implicit_multiplication_application
)


class EvaluateSolver:

    def solve(self, content: str):

        steps = []
        steps_latex = []

        expr_str, var_name, value = (
            self.parse_input(content)
        )

        x = symbols(var_name)

        transformations = (
            standard_transformations +
            (implicit_multiplication_application,)
        )

        expr = parse_expr(
            expr_str,
            transformations=transformations,
            local_dict={var_name: x}
        )

        steps.append("Ta có:")
        steps.append(f"A = {expr}")

        steps.append(
            f"Thay {var_name} = {value} vào biểu thức:"
        )

        steps_latex.append(
            f"A={latex(expr)}"
        )

        substituted = expr.subs(
            x,
            value
        )

        steps.append(
            f"A = {substituted}"
        )

        steps_latex.append(
            f"A={latex(substituted)}"
        )

        result = simplify(
            substituted
        )

        if result != substituted:

            steps.append(
                f"A = {result}"
            )

            steps_latex.append(
                f"A={latex(result)}"
            )

        steps.append(
            f"Vậy giá trị của biểu thức là A = {result}"
        )

        return {
            "result": str(result),
            "latex": latex(result),
            "steps": steps,
            "steps_latex": steps_latex
        }

    def parse_input(self, content):

        content = (
            content.lower()
            .replace("^", "**")
            .replace("²", "**2")
        )

        if "tại" in content:

            expr_part, value_part = (
                content.split("tại")
            )

        elif "với" in content:

            expr_part, value_part = (
                content.split("với")
            )

        else:

            raise Exception(
                "Thiếu giá trị thay vào"
            )

        expr_part = (
            expr_part
            .replace("tính giá trị biểu thức", "")
            .replace("a=", "")
            .replace("a =", "")
            .strip()
        )

        var_name, value = (
            value_part
            .replace(" ", "")
            .split("=")
        )

        return (
            expr_part,
            var_name,
            sympify(value)
        )

