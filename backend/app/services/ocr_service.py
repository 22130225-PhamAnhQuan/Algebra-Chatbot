from pix2tex.cli import LatexOCR

from PIL import Image


class OCRService:

    def __init__(self):

        self.model = LatexOCR()

    def extract_latex(
        self,
        image_path: str
    ):

        try:

            # OPEN IMAGE
            image = Image.open(
                image_path
            )

            # OCR
            latex = self.model(
                image
            )

            return latex.strip()

        except Exception as e:

            raise Exception(
                f"OCR failed: {str(e)}"
            )