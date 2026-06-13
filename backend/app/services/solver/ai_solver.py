import os
import requests
from app.core.config import OLLAMA_URL

_SYSTEM_PROMPT = """
Bạn là Gia sư Toán học AI. Nhiệm vụ của bạn là giải các bài toán đại số hoặc toán đố lập phương trình một cách ngắn gọn, dễ hiểu theo đúng cấu trúc sư phạm THCS tại Việt Nam.

📌 QUY TẮC BẮT BUỘC:
1. Trình bày lời giải bằng tiếng Việt chuẩn.
2. Mọi công thức, ký hiệu toán học phải được định dạng bằng mã LaTeX thuần túy.
3. Cấu trúc lời giải gồm:
   - Phân tích đề bài.
   - Các bước giải chi tiết.
   - Kiểm tra điều kiện.
4. Dòng cuối cùng BẮT BUỘC phải chứa từ "✅ Kết quả:" kèm theo đáp số cuối cùng.
""".strip()

class AISolver:
    def __init__(self):
        self.model = os.getenv("OLLAMA_MODEL", "phi3:mini")
        self.timeout = 60

    def solve(self, content: str, grade_id: int = None, chapter_id: int = None, lesson_id: int = None) -> dict:
        try:
            target_url = OLLAMA_URL if OLLAMA_URL.endswith("/api/chat") else OLLAMA_URL.rstrip("/") + "/api/chat"

            response = requests.post(
                target_url,
                json={
                    "model": self.model,
                    "stream": False,
                    "messages": [
                        {"role": "system", "content": _SYSTEM_PROMPT},
                        {"role": "user", "content": f"Giải bài toán cấp 2 sau:\n{content}"},
                    ],
                    "options": {"temperature": 0.1, "num_predict": 1200},
                },
                timeout=self.timeout,
            )
            response.raise_for_status()
            raw = response.json().get("message", {}).get("content", "").strip()

            if not raw:
                raise ValueError("AI trả về nội dung rỗng")

            steps = [line for line in raw.split("\n") if line.strip()]
            result = self._extract_result(steps)

            return {
                "result": result,
                "latex": result,
                "steps_latex": steps,
                "solver": "ai"
            }

        except Exception as e:
            raise ValueError(f"Lỗi AI Solver: {str(e)}")

    def _extract_result(self, steps: list[str]) -> str:
        for line in reversed(steps):
            if "✅" in line or "Kết quả:" in line:
                return line.replace("✅", "").replace("Kết quả:", "").strip()
        return "Xem chi tiết trong các bước giải"