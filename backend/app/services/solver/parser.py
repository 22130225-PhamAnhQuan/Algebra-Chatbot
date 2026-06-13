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

    text = text.replace("³", "**3")

    text = text.replace(":", "/")
    text = text.replace("÷", "/")
    text = text.replace("×", "*")
    text = text.replace("−", "-")

    return text


def parse_equation(content: str):
    content = normalize(content)
    lhs, rhs = content.split("=")

    vars_found = []
    for c in content:
        if c.isalpha() and c not in vars_found:
            vars_found.append(c)

    if not vars_found:
        var_name = "x"
        symbols_dict = {"x": symbols("x")}
    else:
        var_name = vars_found[0]
        symbols_dict = {v: symbols(v) for v in vars_found}

    lhs_expr = parse_expr(lhs, transformations=transformations, local_dict=symbols_dict)
    rhs_expr = parse_expr(rhs, transformations=transformations, local_dict=symbols_dict)

    return (symbols_dict[var_name], lhs_expr, rhs_expr, var_name)