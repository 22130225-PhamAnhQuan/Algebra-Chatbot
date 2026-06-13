from app.services.solver.graph.linear_graph_solver import LinearGraphSolver
from app.services.solver.graph.quadratic_graph_solver import QuadraticGraphSolver
from app.services.solver.graph.system_graph_solver import SystemGraphSolver
from app.services.solver.graph.find_function_solver import FindFunctionSolver

class GraphSolver:
    def solve(self, content: str):
        text = content.lower()

        # Dạng 1: Viết phương trình đường thẳng đi qua 2 điểm
        if "đi qua" in text or "viết phương trình" in text:
            return FindFunctionSolver().solve(content)

        # Dạng 2: Tìm giao điểm 2 đồ thị (Nhập y = ... ; y = ...)
        if ";" in text and text.count("y") >= 2:
            return SystemGraphSolver().solve(content)

        # Dạng 3: Vẽ đồ thị Parabol (Có x^2)
        if "x^2" in text or "x**2" in text or "x²" in text:
            return QuadraticGraphSolver().solve(content)

        # Dạng 4: Vẽ đồ thị Đường thẳng
        return LinearGraphSolver().solve(content)