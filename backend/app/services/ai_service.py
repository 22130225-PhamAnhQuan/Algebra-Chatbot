import logging
import requests
from app.core.config import OLLAMA_URL
from app.services.context_service import build_context

logger = logging.getLogger(__name__)


def generate_ai_response(db, conversation_id: int, question: str) -> str:
    try:
        context = build_context(db, conversation_id)
        if not context:
            return "Không tìm thấy dữ liệu cuộc hội thoại."
    except Exception as e:
        logger.error(f"Error building context: {e}")
        return "Có lỗi khi xử lý ngữ cảnh bài toán."

    messages = [
        {
            "role": "system",
            "content": f"""
            Bạn là Gia sư Toán THCS. 

            BÀI TOÁN HỌC SINH ĐANG HỎI:
            {context.get('problem')}

            CÁC BƯỚC GIẢI HIỆN TẠI:
            {context.get('solution')}

            QUY TẮC:
            - Dựa vào Đề bài và Bước giải ở trên để trả lời thắc mắc của học sinh.
            - Không giải lại cả bài toán. Trả lời ngắn gọn, thân thiện (dưới 150 chữ).
            - Mọi công thức toán học phải bọc trong thẻ LaTeX.
            - Nếu câu hỏi không liên quan đến bài toán này, hãy lịch sự từ chối.
            """
        }
    ]

    for msg in context.get("history", []):
        messages.append({"role": msg.get("role", "user"), "content": msg.get("content", "")})

    messages.append({"role": "user", "content": question})

    try:
        base_url = OLLAMA_URL.replace("/api/generate", "").rstrip("/")
        target_url = f"{base_url}/api/chat"

        response = requests.post(
            target_url,
            json={
                "model": "phi3:mini",
                "stream": False,
                "messages": messages,
                "options": {
                    "temperature": 0.3,
                    "num_predict": 500
                }
            },
            timeout=180
        )
        response.raise_for_status()
        data = response.json()
        return data.get("message", {}).get("content", "Lỗi xử lý phản hồi từ AI.")

    except requests.exceptions.ConnectionError:
        logger.error("Cannot connect to Ollama")
        return "Hệ thống Gia sư AI hiện không khả dụng, em vui lòng thử lại sau nhé."
    except Exception as e:
        logger.error(f"Ollama error: {e}")
        return "Có lỗi xảy ra trong quá trình suy luận của AI."