from sympy import symbols, Eq, solve, sympify
from sympy.plotting import plot
import base64
from io import BytesIO
import matplotlib.pyplot as plt

x = symbols('x')


def solve_linear_equation(expr: str):
    try:
        left, right = expr.split("=")
        equation = Eq(sympify(left), sympify(right))
        result = solve(equation, x)

        return {
            "type": "equation",
            "input": expr,
            "result": str(result),
            "steps": f"Giải phương trình {expr} → x = {result}"
        }
    except Exception as e:
        return {"error": str(e)}


def plot_graph(expr: str):
    try:
        y_expr = sympify(expr)

        xs = [i for i in range(-10, 11)]
        ys = [float(y_expr.subs(x, val)) for val in xs]

        plt.figure()
        plt.plot(xs, ys)
        plt.axhline(0)
        plt.axvline(0)

        buffer = BytesIO()
        plt.savefig(buffer, format='png')
        buffer.seek(0)

        img_base64 = base64.b64encode(buffer.read()).decode()

        return {
            "type": "graph",
            "image": img_base64
        }

    except Exception as e:
        return {"error": str(e)}