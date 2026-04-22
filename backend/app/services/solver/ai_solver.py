import requests
import json
from app.core.config import OLLAMA_URL

def solve_with_ai(content: str):
    # PROMPT KỸ THUẬT: Đưa ra cấu trúc JSON làm khuôn mẫu cứng
    prompt = f"""
    Bạn là giáo viên toán THCS. Hãy giải bài toán sau: '{content}'

    YÊU CẦU BẮT BUỘC:
    1. Trình bày từng bước giải rõ ràng, dễ hiểu cho học sinh.
    2. Bạn CHỈ ĐƯỢC PHÉP trả về kết quả dưới định dạng JSON chính xác như sau, không giải thích gì thêm ngoài JSON:
    {{
        "result": "Đáp án cuối cùng ngắn gọn (VD: x = 2)",
        "steps": [
            "Bước 1: ...",
            "Bước 2: ..."
        ],
        "latex": "Chuỗi công thức latex của đáp án cuối cùng"
    }}
    """

    try:
        response = requests.post(OLLAMA_URL, json={
            "model": "phi3",
            "prompt": prompt,
            "format": "json",  # QUAN TRỌNG: Ép Ollama chỉ trả về JSON
            "stream": False
        })

        # Kiểm tra nếu API gọi thất bại (VD: quên bật Ollama)
        response.raise_for_status()

        data = response.json()
        text_response = data.get("response", "{}")

        # Ép kiểu chuỗi JSON an toàn thành Dictionary
        parsed_data = json.loads(text_response)

        return {
            "result": parsed_data.get("result", "Không rõ kết quả"),
            "steps": parsed_data.get("steps", ["AI không cung cấp các bước giải."]),
            "latex": parsed_data.get("latex", "")
        }

    except json.JSONDecodeError:
        print("[AI Error] Phi-3 không tuân thủ định dạng JSON.")
        return {
            "result": None,
            "steps": ["Lỗi đọc dữ liệu từ AI. Vui lòng thử lại!"],
            "latex": ""
        }
    except Exception as e:
        print(f"[AI Server Error] {e}")
        return {
            "result": None,
            "steps": ["Hệ thống AI đang bận hoặc chưa khởi động.", "Vui lòng kiểm tra server!"],
            "latex": ""
        }