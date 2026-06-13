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

            if not latex:
                return ""

            cleaned_latex = latex.strip()

            tags_to_remove = [
                r"\scriptstyle", r"\textstyle", r"\displaystyle", r"\small",
                r"\;", r"\,", r"\!", r"\quad"
            ]
            for tag in tags_to_remove:
                cleaned_latex = cleaned_latex.replace(tag, "")

            cleaned_latex = cleaned_latex.replace(r"\left", "")
            cleaned_latex = cleaned_latex.replace(r"\right", "")

            cleaned_latex = re.sub(r'\s+', ' ', cleaned_latex).strip()

            logger.info(f"OCR trích xuất thành công: {cleaned_latex}")

            return cleaned_latex

        except Exception as e:
            logger.error(f"Lỗi module OCR tại {image_path}: {str(e)}")
            raise Exception(f"Không thể nhận diện hình ảnh. Vui lòng chụp lại rõ nét hơn.")