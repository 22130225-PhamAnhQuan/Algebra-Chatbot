from sympy import *
from sympy.parsing.sympy_parser import (
    parse_expr,
    standard_transformations,
    implicit_multiplication_application
)

transformations = (
    standard_transformations +
    (implicit_multiplication_application,)
)


def normalize(text: str):

    text = text.lower()

    text = text.replace("^", "**")

    text = text.replace("²", "**2")

    text = text.replace(" ", "")

    return text


def parse_equation(content: str):

    content = normalize(content)

    lhs, rhs = content.split("=")

    vars_found = list(set([
        c for c in content
        if c.isalpha()
    ]))

    var_name = vars_found[0]

    x = symbols(var_name)

    lhs_expr = parse_expr(
        lhs,
        transformations=transformations,
        local_dict={var_name: x}
    )

    rhs_expr = parse_expr(
        rhs,
        transformations=transformations,
        local_dict={var_name: x}
    )

    return (
        x,
        lhs_expr,
        rhs_expr,
        var_name
    )