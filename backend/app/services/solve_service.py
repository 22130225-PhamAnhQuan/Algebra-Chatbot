import logging
import re
from itertools import zip_longest

from app.services.solver.ai_solver import AISolver
from app.services.solver.grade_factory import get_grade_solver

logger = logging.getLogger(__name__)

_AI_SOLVER = AISolver()

def clean_text_step(text: str):
    text = str(text).strip()
    if not text:
        return ""

    if "\\" not in text and "^" not in text:
        text = text.replace("*", "·")
        text = re.sub(r"\(([-]?\d+)\)", r"\1", text)
        text = text.replace("+", " + ").replace("=", " = ")
        text = re.sub(r"\s+", " ", text).strip()
    return text


def optimize_steps_pair(raw_steps: list, raw_latex_steps: list = None):
    cleaned_steps = []
    cleaned_latex = []

    if raw_latex_steps is None:
        raw_latex_steps = [""] * len(raw_steps)

    for step, latex_step in zip_longest(raw_steps, raw_latex_steps, fillvalue=""):
        clean_step = clean_text_step(step)

        if (
                not cleaned_steps
                or clean_step != cleaned_steps[-1]
                or latex_step != cleaned_latex[-1]
        ):
            cleaned_steps.append(clean_step)
            cleaned_latex.append(latex_step)

    return cleaned_steps, cleaned_latex

def solve_math(
        content: str,
        grade_id: int | None = None,
        chapter_id: int | None = None,
        lesson_id: int | None = None
):
    logger.info("Solving Request -> Grade=%s Chapter=%s Lesson=%s", grade_id, chapter_id, lesson_id)

    has_many_words = len(re.findall(r"[^\W\d_]+", content)) > 15

    if has_many_words:
        logger.info("Phát hiện Toán đố (Word problem) -> Chuyển luồng sang AI Solver")
        result = _solve_ai(content, grade_id, chapter_id, lesson_id)
        result["problem_type"] = "word_problem"
        return result

    try:
        # Tự động gọi trạm gác Grade_Solver tương ứng, nó sẽ tự detect dạng bài
        grade_solver = get_grade_solver(grade_id)
        result = grade_solver.solve(content)

        # Xử lý đồng bộ trường dữ liệu steps và steps_latex an toàn
        if "steps_latex" not in result:
            result["steps_latex"] = result.get("steps", [])

        is_all_empty = all(str(s).strip() == "" for s in result.get("steps", []))
        if not result.get("steps") or is_all_empty:
            result["steps"] = list(result["steps_latex"])

        # Tối ưu hóa để chống lặp bước
        steps, latex_steps = optimize_steps_pair(
            result["steps"],
            result["steps_latex"]
        )

        result["steps"] = steps
        result["steps_latex"] = latex_steps

        if "problem_type" not in result:
            result["problem_type"] = "algebra_math"

        result["solver"] = "sympy"

        return result

    except Exception as e:
        logger.warning(f"SymPy giải thất bại -> Kích hoạt AI Fallback. Lỗi: {str(e)}")
        result = _solve_ai(content, grade_id, chapter_id, lesson_id)
        result["problem_type"] = "fallback_ai"
        return result


def _solve_ai(
        content: str,
        grade_id=None,
        chapter_id=None,
        lesson_id=None
):
    try:
        result = _AI_SOLVER.solve(
            content=content,
            grade_id=grade_id,
            chapter_id=chapter_id,
            lesson_id=lesson_id
        )

        if "steps" in result and isinstance(result["steps"], list):
            steps, latex_steps = optimize_steps_pair(
                result["steps"],
                result.get("steps_latex", [])
            )
            result["steps"] = steps
            result["steps_latex"] = latex_steps

        result["solver"] = "ai"
        return result

    except Exception as e:
        logger.error(f"AI Solver Error: {str(e)}")
        return {
            "success": False,
            "solver": "error",
            "result": "Không thể giải bài toán",
            "latex": r"\text{Lỗi hệ thống AI}",
            "steps": ["Không thể xử lý bài toán. Vui lòng kiểm tra lại kết nối AI."],
            "steps_latex": [r"\text{Không thể xử lý bài toán. Vui lòng kiểm tra lại kết nối AI.}"]
        }