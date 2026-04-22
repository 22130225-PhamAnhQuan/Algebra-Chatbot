import sympy as sp


def solve_system(content: str):
    x, y = sp.symbols('x y')

    eq1, eq2 = content.split(";")

    eq1 = sp.sympify(eq1.replace("=", "-(") + ")")
    eq2 = sp.sympify(eq2.replace("=", "-(") + ")")

    sol = sp.solve((eq1, eq2), (x, y))

    steps = [
        "Lập hệ phương trình",
        "Giải hệ",
        f"x = {sol[x]}, y = {sol[y]}"
    ]

    return {
        "result": f"x = {sol[x]}, y = {sol[y]}",
        "steps": steps,
        "latex": f"x={sp.latex(sol[x])}, y={sp.latex(sol[y])}"
    }