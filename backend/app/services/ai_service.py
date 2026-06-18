# import logging
# import requests
# from app.core.config import OLLAMA_URL
# from app.services.context_service import build_context
#
# logger = logging.getLogger(__name__)
#
#
# def generate_ai_response(db, conversation_id: int, question: str) -> str:
#     try:
#         context = build_context(db, conversation_id)
#         if not context:
#             return "Không tìm thấy dữ liệu cuộc hội thoại."
#     except Exception as e:
#         logger.error(f"Error building context: {e}")
#         return "Có lỗi khi xử lý ngữ cảnh bài toán."
#
#     messages = [
#         {
#             "role": "system",
#             "content": f"""
#             Bạn là Gia sư Toán THCS.
#
#             BÀI TOÁN HỌC SINH ĐANG HỎI:
#             {context.get('problem')}
#
#             CÁC BƯỚC GIẢI HIỆN TẠI:
#             {context.get('solution')}
#
#             QUY TẮC:
#             - Dựa vào Đề bài và Bước giải ở trên để trả lời thắc mắc của học sinh.
#             - KHÔNG giải lại toàn bộ bài toán. Chỉ giải thích đúng chỗ học sinh hỏi.
#             - Trả lời ngắn gọn, thân thiện, dễ hiểu dành cho học sinh THCS (tối đa 150 chữ).
#             - Mọi công thức toán học phải bọc trong thẻ LaTeX.
#             - Nếu câu hỏi không liên quan đến Toán học, hãy lịch sự từ chối.
#             """
#         }
#     ]
#
#     for msg in context.get("history", []):
#         messages.append({"role": msg.get("role", "user"), "content": msg.get("content", "")})
#
#     messages.append({"role": "user", "content": question})
#
#     try:
#         base_url = OLLAMA_URL.replace("/api/generate", "").rstrip("/")
#         target_url = f"{base_url}/api/chat"
#
#         response = requests.post(
#             target_url,
#             json={
#                 "model": "phi3:mini",
#                 "stream": False,
#                 "messages": messages,
#                 "options": {
#                     "temperature": 0.3,
#                     "num_predict": 500
#                 }
#             },
#             timeout=180
#         )
#         response.raise_for_status()
#         data = response.json()
#         return data.get("message", {}).get("content", "Lỗi xử lý phản hồi từ AI.")
#
#     except requests.exceptions.ConnectionError:
#         logger.error("Cannot connect to Ollama")
#         return "Hệ thống Gia sư AI hiện không khả dụng, em vui lòng thử lại sau nhé."
#     except Exception as e:
#         logger.error(f"Ollama error: {e}")
#         return "Có lỗi xảy ra trong quá trình suy luận của AI."

import logging
import os
import google.generativeai as genai
from app.services.context_service import build_context
from app.core.config import GEMINI_API_KEY  # Đã lấy từ config.py

logger = logging.getLogger(__name__)

# Cấu hình API Key từ file config
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
else:
    logger.error("GEMINI_API_KEY không tồn tại trong file cấu hình!")


def generate_ai_response(db, conversation_id: int, question: str) -> str:
    # 1. Lấy ngữ cảnh
    try:
        context = build_context(db, conversation_id)
        if not context:
            return "Không tìm thấy dữ liệu cuộc hội thoại."
    except Exception as e:
        logger.error(f"Error building context: {e}")
        return "Có lỗi khi xử lý ngữ cảnh bài toán."

    # 2. Định nghĩa System Instruction
    system_instruction = f"""
    Bạn là Gia sư Toán THCS. 

    BÀI TOÁN HỌC SINH ĐANG HỎI:
    {context.get('problem')}

    CÁC BƯỚC GIẢI HIỆN TẠI:
    {context.get('solution')}

    QUY TẮC:
    - Dựa vào Đề bài và Bước giải ở trên để trả lời thắc mắc của học sinh.
    - KHÔNG giải lại toàn bộ bài toán. Chỉ giải thích đúng chỗ học sinh hỏi.
    - Trả lời ngắn gọn, thân thiện, dễ hiểu dành cho học sinh THCS (tối đa 150 chữ).
    - Mọi công thức toán học phải bọc trong thẻ LaTeX.
    - Nếu câu hỏi không liên quan đến Toán học, hãy lịch sự từ chối.
    """

    # 3. Chuyển đổi lịch sử chat từ DB sang định dạng của Gemini
    gemini_history = []
    for msg in context.get("history", []):
        # Database của em dùng 'assistant', Gemini cần 'model'
        role = "model" if msg.get("role") == "assistant" else "user"
        gemini_history.append({
            "role": role,
            "parts": [msg.get("content", "")]
        })

    # 4. Gọi API Gemini
    try:
        model = genai.GenerativeModel(
            model_name="gemini-1.5-pro",
            system_instruction=system_instruction,
            generation_config=genai.GenerationConfig(
                temperature=0.3,
                max_output_tokens=1500
            )
        )

        # Bắt đầu phiên chat và gửi tin nhắn
        chat = model.start_chat(history=gemini_history)
        response = chat.send_message(question)

        return response.text

    except Exception as e:
        logger.error(f"Gemini error: {e}")
        return "Hệ thống Gia sư AI hiện không khả dụng, em vui lòng thử lại sau nhé."