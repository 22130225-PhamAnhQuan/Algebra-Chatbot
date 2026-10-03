import base64
import requests
import logging
from PIL import Image
from pix2tex.cli import LatexOCR
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger(__name__)

try:
    local_model = LatexOCR()
except Exception as e:
    logger.warning(f"Không thể khởi tạo LatexOCR cục bộ: {e}")
    local_model = None

class OCRService:
    def __init__(self):
        self.model = local_model

    def extract_latex(self, image_path: str) -> str:
        # 1. Thử nhận diện bằng Gemini 1.5 Flash trước vì độ chính xác rất cao
        if GEMINI_API_KEY:
            try:
                logger.info("Bắt đầu nhận diện ảnh bằng Gemini 1.5 Flash...")
                
                # Xác định định dạng MIME của ảnh
                mime_type = "image/png"
                if image_path.lower().endswith((".jpg", ".jpeg")):
                    mime_type = "image/jpeg"
                elif image_path.lower().endswith(".webp"):
                    mime_type = "image/webp"

                with open(image_path, "rb") as image_file:
                    image_data = base64.b64encode(image_file.read()).decode("utf-8")

                url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
                payload = {
                    "contents": [
                        {
                            "parts": [
                                {
                                    "text": "Hãy trích xuất công thức hoặc phương trình toán học từ ảnh này dưới dạng mã văn bản (chỉ trả về phần công thức cốt lõi, không chứa chữ tiếng Việt giải thích, không chứa ký tự bọc ngoài như $ hoặc $$, ví dụ: '2x - 4 = 0' hoặc 'a + b = 3; a - b = 1'). Lưu ý đặc biệt: Nếu trong ảnh chụp có nhiều hơn một bài toán/công thức toán, hãy chỉ trích xuất duy nhất công thức toán đầu tiên (ở vị trí trên cùng hoặc nổi bật nhất) để hệ thống xử lý giải bài toán đó, bỏ qua các bài toán còn lại."
                                },
                                {
                                    "inlineData": {
                                        "mimeType": mime_type,
                                        "data": image_data
                                    }
                                }
                            ]
                        }
                    ]
                }

                response = requests.post(url, json=payload, timeout=15)
                response.raise_for_status()
                data = response.json()
                
                text_result = data['candidates'][0]['content']['parts'][0]['text']
                cleaned = text_result.strip().replace("```latex", "").replace("```", "").strip()
                
                if cleaned:
                    logger.info(f"Gemini OCR trích xuất thành công: {cleaned}")
                    return cleaned
            except Exception as e:
                logger.error(f"Lỗi khi dùng Gemini OCR: {str(e)}. Tự động chuyển sang LatexOCR cục bộ.")

        # 2. Fallback sang LatexOCR cục bộ
        if self.model:
            try:
                logger.info("Bắt đầu nhận diện bằng LatexOCR cục bộ...")
                image = Image.open(image_path)
                latex = self.model(image)

                if not latex:
                    return ""

                cleaned = latex.strip()
                tags_to_remove = [
                    r"\scriptstyle", r"\textstyle", r"\displaystyle",
                    r"\small", r"\quad", r"\mathrm"
                ]
                for tag in tags_to_remove:
                    cleaned = cleaned.replace(tag, "")

                logger.info(f"LatexOCR trích xuất thô: {cleaned}")
                return cleaned
            except Exception as e:
                logger.error(f"Lỗi LatexOCR cục bộ: {str(e)}")
                raise Exception("Không thể nhận diện hình ảnh. Vui lòng chụp lại rõ nét hơn.")
        else:
            raise Exception("Hệ thống nhận diện hiện tại không khả dụng. Vui lòng chụp lại rõ nét hơn.")