import logging
import re

from app.services.solver.detector import detect_type
from app.services.solver.linear_solver import LinearSolver
from app.services.solver.quadratic_solver import QuadraticSolver
from app.services.solver.system_solver import SystemSolver
from app.services.solver.fraction_solver import FractionSolver
from app.services.solver.inequality_solver import InequalitySolver
from app.services.solver.simplify_solver import SimplifySolver
from app.services.solver.ai_solver import AISolver

logger = logging.getLogger(__name__)

_SOLVERS = {
    "linear": LinearSolver(),
    "quadratic": QuadraticSolver(),
    "system": SystemSolver(),
    "fraction": FractionSolver(),
    "inequality": InequalitySolver(),
    "simplify": SimplifySolver(),
}
_AI_SOLVER = AISolver()

_RULE_BASED_TYPES = set(_SOLVERS.keys())


def clean_step(text: str) -> str:
    """Làm sạch 1 dòng step: Xóa *, format ngoặc và khoảng trắng"""
    text = str(text)
    text = text.replace("*", "")
    # Xóa ngoặc quanh số nguyên: (10) -> 10, (-10) -> -10
    text = re.sub(r'\(([-]?\d+)\)', r'\1', text)
    # Căn chỉnh khoảng trắng cho đẹp
    text = text.replace("+", " + ").replace("=", " = ")
    text = re.sub(r'(?<!\s)-(?!\s)', ' - ', text)
    # Gom khoảng trắng thừa
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def optimize_steps(raw_steps: list) -> list:
    """Lọc mảng steps: Xóa các bước trùng lặp liên tiếp"""
    cleaned = []
    for step in raw_steps:
        c_step = clean_step(step)

        if not cleaned or c_step != cleaned[-1]:
            cleaned.append(c_step)
    return cleaned


# ==========================================


def solve_math(content: str) -> dict:
    problem_type = detect_type(content)
    logger.info("Detected type: %s | content: %.80s", problem_type, content)

    if problem_type in _RULE_BASED_TYPES:
        result = _solve_rule_based(content, problem_type)
    else:
        logger.info("Type '%s' → AI solver", problem_type)
        result = _solve_ai(content)

    result["problem_type"] = problem_type

    return result


def _solve_rule_based(content: str, problem_type: str) -> dict:
    """Giải bằng sympy. Nếu fail → fallback AI."""
    try:
        solver = _SOLVERS[problem_type]
        result = solver.solve(content)

        if "steps" in result and isinstance(result["steps"], list):
            result["steps"] = optimize_steps(result["steps"])

        logger.info("Rule-based OK: %s", problem_type)
        return {**result, "solver": problem_type}

    except Exception as e:
        logger.warning("Rule-based fail (%s): %s → fallback AI", problem_type, e)
        return _solve_ai(content)


def _solve_ai(content: str) -> dict:
    """Giải bằng Phi-3 Mini. Nếu fail → trả error rõ ràng."""
    try:
        result = _AI_SOLVER.solve(content)

        # LỌC RÁC CHO AI SOLVER (Phòng hờ AI bị "nói nhịu", lặp từ)
        if "steps" in result and isinstance(result["steps"], list):
            result["steps"] = optimize_steps(result["steps"])

        logger.info("AI solver OK")
        return {**result, "solver": "ai"}

    except Exception as e:
        logger.error("AI solver fail: %s", e)
        return {
            "success": False,
            "solver": "error",
            "result": "Không thể giải bài toán này",
            "steps": [
                "⚠️ Hệ thống gặp lỗi khi xử lý bài toán.",
                f"Chi tiết: {e}",
                "💡 Hãy thử diễn đạt lại đề bài rõ hơn.",
            ],
        }