from pix2tex.cli import LatexOCR
from PIL import Image
import re
import logging

logger = logging.getLogger(__name__)

class OCRService:
    def __init__(self):
        self.model = LatexOCR()

    def extract_latex(self, image_path: str) -> str:
        try:
            image = Image.open(image_path)
            latex = self.model(image)
            if not latex: return ""

            # 1. Làm sạch cơ bản
            cleaned = latex.strip()

            tags_to_remove = [r"\scriptstyle", r"\textstyle", r"\displaystyle", r"\small", r"\,", r"\;", r"\!",
                              r"\quad", r"\mathrm", r"\text"]
            for tag in tags_to_remove:
                cleaned = cleaned.replace(tag, "")

            # 2. Xử lý khoảng trắng và ngoặc
            cleaned = cleaned.replace(r"\left", "").replace(r"\right", "").replace(" ", "")

            cleaned = re.sub(r'(\d)([a-zA-Z])', r'\1*\2', cleaned)

            # 4. Thay các ký tự lạ thành ký tự SymPy hiểu
            cleaned = cleaned.replace(r"\cdot", "*").replace("×", "*")

            # 5. Đảm bảo dấu bằng không bị lỗi cách
            cleaned = cleaned.replace("=", "=")

            logger.info(f"OCR trích xuất sau khi làm sạch: {cleaned}")
            return cleaned
        except Exception as e:
            logger.error(f"Lỗi module OCR tại {image_path}: {str(e)}")
            raise Exception(f"Không thể nhận diện hình ảnh. Vui lòng chụp lại rõ nét hơn.")