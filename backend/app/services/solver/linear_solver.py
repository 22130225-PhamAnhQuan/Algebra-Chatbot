import sympy as sp


def solve_linear(content: str):
    x = sp.symbols('x')

    eq = sp.sympify(content.replace("=", "-(") + ")")
    solution = sp.solve(eq, x)

    steps = [
        f"Chuyển về dạng: {eq} = 0",
        "Giải phương trình",
        f"x = {solution[0]}"
    ]

    return {
        "result": f"x = {solution[0]}",
        "steps": steps,
        "latex": sp.latex(solution[0])
    }