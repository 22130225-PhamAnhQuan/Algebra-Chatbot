import sympy as sp


def solve_quadratic(content: str):
    x = sp.symbols('x')

    eq = sp.sympify(content.replace("=", "-(") + ")")
    solutions = sp.solve(eq, x)

    steps = [
        f"Đưa về dạng chuẩn: {eq} = 0",
        "Áp dụng công thức nghiệm",
        f"x1 = {solutions[0]}, x2 = {solutions[1]}"
    ]

    return {
        "result": f"x1 = {solutions[0]}, x2 = {solutions[1]}",
        "steps": steps,
        "latex": ", ".join([sp.latex(s) for s in solutions])
    }