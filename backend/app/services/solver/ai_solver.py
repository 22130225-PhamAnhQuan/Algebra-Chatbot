import os
import requests
from app.core.config import OLLAMA_URL


_SYSTEM_PROMPT = """
Bạn là AlgebraBot — gia sư toán THCS. Giải bài toán đại số theo đúng format sau:

📌 **Phân tích:** [nhận dạng dạng bài]
📌 **Bước 1:** [nội dung + phép tính cụ thể]
📌 **Bước 2:** [nội dung + phép tính cụ thể]
...
📌 **Kiểm tra:** [thay đáp án vào bài gốc]
✅ **Kết quả:** [đáp án cuối kèm đơn vị]

Quy tắc:
- Mỗi bước phải có phép tính số cụ thể, không chỉ mô tả
- Nếu PT bậc 2: tính Delta, xét 3 trường hợp
- Nếu căn thức: nêu điều kiện xác định trước
- Nếu bất PT: xét chiều khi nhân/chia số âm
- Trả lời bằng tiếng Việt
- Nếu không chắc, ghi "Cần kiểm tra lại"
""".strip()


class AISolver:

    # fix: đọc model từ env thay vì hardcode
    def __init__(self):
        self.model   = os.getenv("OLLAMA_MODEL", "phi3:mini")
        self.timeout = 60  # fix: thêm timeout tránh treo

    def solve(self, content: str) -> dict:
        try:
            # fix: dùng /api/chat + messages thay vì /api/generate + prompt đơn
            # → có system prompt, model hiểu context và format đúng hơn
            response = requests.post(
                OLLAMA_URL,
                json={
                    "model":  self.model,
                    "stream": False,
                    "messages": [
                        {"role": "system", "content": _SYSTEM_PROMPT},
                        {"role": "user",   "content": f"Giải bài toán sau:\n{content}"},
                    ],
                    "options": {
                        "temperature":    0.1,   # thấp = nhất quán hơn với toán
                        "num_predict":    1200,
                        "repeat_penalty": 1.1,
                    },
                },
                timeout=self.timeout,  # fix: thêm timeout
            )

            # fix: kiểm tra HTTP status trước khi parse
            response.raise_for_status()
            data = response.json()

            # fix: /api/chat trả về data["message"]["content"]
            # khác /api/generate trả về data["response"]
            raw = data.get("message", {}).get("content", "").strip()

            if not raw:
                raise ValueError("Phi-3 Mini trả về nội dung rỗng")

            # fix: tách thành list steps thay vì nhét 1 cục
            steps  = [line for line in raw.split("\n") if line.strip()]
            result = self._extract_result(steps)

            return {"result": result, "steps": steps}

        # fix: xử lý từng loại lỗi cụ thể
        except requests.exceptions.ConnectionError:
            raise ValueError(
                "Không kết nối được Ollama. Chạy: `ollama serve`"
            )
        except requests.exceptions.Timeout:
            raise ValueError(
                f"Ollama timeout sau {self.timeout}s. "
                "Model đang load lần đầu — thử lại sau."
            )
        except requests.exceptions.HTTPError as e:
            raise ValueError(f"Ollama lỗi HTTP {e.response.status_code}")
        except (KeyError, ValueError) as e:
            raise ValueError(f"Lỗi xử lý response: {e}")

    def _extract_result(self, steps: list[str]) -> str:
        """Lấy dòng có ✅ làm result ngắn gọn"""
        for line in reversed(steps):
            if "✅" in line or "kết quả" in line.lower():
                return (line
                        .replace("✅", "")
                        .replace("**Kết quả:**", "")
                        .strip())
        return steps[-1] if steps else ""