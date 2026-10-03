import re as regex
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


def latex_to_python_syntax(text: str) -> str:
    # 1. Thay thế các nhóm \frac{a}{b} thành ((a)/(b)) đệ quy
    pattern_frac = r'\\frac\s*\{([^{}]+)\}\s*\{([^{}]+)\}'
    while regex.search(pattern_frac, text):
        text = regex.sub(pattern_frac, r'((\1)/(\2))', text)
        
    # 2. Thay thế \sqrt{a} thành ((a)**(0.5)) đệ quy
    pattern_sqrt = r'\\sqrt\s*\{([^{}]+)\}'
    while regex.search(pattern_sqrt, text):
        text = regex.sub(pattern_sqrt, r'((\1)**(0.5))', text)
        
    # 3. Loại bỏ các ký tự rác LaTeX khác
    text = text.replace(r"\left(", "(").replace(r"\right)", ")")
    text = text.replace(r"\left[", "[").replace(r"\right]", "]")
    text = text.replace(r"\cdot", "*")
    return text


def normalize(text: str):
    text = latex_to_python_syntax(text)
    text = text.lower()

    text = regex.sub(r'(\d+)\\times([\+\-\/\)\=])', r'\1*x\2', text)
    text = regex.sub(r'(\d+)\\times$', r'\1*x', text)

    text = text.replace(r"\times", "*")
    text = text.replace("×", "*")

    text = regex.sub(r'\^\{([^}]+)\}', r'**(\1)', text)
    text = text.replace("^", "**")
    text = text.replace("²", "**2")
    text = text.replace("³", "**3")
    text = text.replace(" ", "")
    text = text.replace(":", "/")
    text = text.replace("÷", "/")
    text = text.replace("−", "-")

    # 4. Chèn dấu * vào các vị trí ẩn (VD: 2x -> 2*x)
    text = regex.sub(r'(\d)([a-z])', r'\1*\2', text)
    text = regex.sub(r'(\d)(\()', r'\1*\2', text)
    text = regex.sub(r'(\))([a-z])', r'\1*\2', text)
    text = regex.sub(r'(\))(\()', r'\1*\2', text)

    text = text.replace("{", "(").replace("}", ")")

    return text

def parse_equation(content: str):
    content = normalize(content)

    if "=" in content:
        lhs, rhs = content.split("=", 1)
    else:
        lhs = content
        rhs = "0"  # Mặc định vế phải bằng 0 nếu học sinh không nhập

    lhs_expr = parse_expr(lhs, transformations=transformations)
    rhs_expr = parse_expr(rhs, transformations=transformations)

    all_symbols = lhs_expr.free_symbols.union(rhs_expr.free_symbols)

    if not all_symbols:
        var_name = "x"
        main_var = symbols("x")
    else:
        # Lấy biến đầu tiên tìm được (có thể sort để ưu tiên x, y)
        sorted_symbols = sorted(list(all_symbols), key=lambda s: s.name)
        main_var = sorted_symbols[0]
        var_name = main_var.name

    return (main_var, lhs_expr, rhs_expr, var_name)