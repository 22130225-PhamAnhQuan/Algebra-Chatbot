from pix2tex.cli import LatexOCR
from PIL import Image
import logging

logger = logging.getLogger(__name__)

model = LatexOCR()

class OCRService:
    def __init__(self):
        self.model = model

    def extract_latex(self, image_path: str) -> str:
        try:
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

            logger.info(f"OCR trích xuất thô: {cleaned}")
            return cleaned

        except Exception as e:
            logger.error(f"Lỗi OCR: {str(e)}")
            raise Exception("Không thể nhận diện hình ảnh. Vui lòng chụp lại rõ nét hơn.")