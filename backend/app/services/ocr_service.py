import easyocr
import io
import numpy as np
import cv2
from PIL import Image
from app.core.exceptions import OCRError

class OcrService:
    # Khởi tạo Reader với tiếng Việt và tiếng Anh.
    # gpu=True nếu máy bạn có card đồ họa NVIDIA, False nếu dùng CPU.
    _reader = None

    @classmethod
    def get_reader(cls):
        if cls._reader is None:
            cls._reader = easyocr.Reader(['vi', 'en'], gpu=False)
        return cls._reader

    @classmethod
    async def extract_text_from_image(cls, image_bytes: bytes) -> str:
        """
        Sử dụng EasyOCR để nhận dạng đề bài từ ảnh chụp.
        """
        try:
            # 1. Chuyển đổi bytes thành mảng numpy để OpenCV xử lý
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            if image is None:
                raise OCRError(detail="Không thể đọc dữ liệu ảnh.")

            # 2. Tiền xử lý ảnh với OpenCV để tăng độ chính xác
            # Chuyển xám và khử nhiễu nhẹ
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            denoised = cv2.fastNlMeansDenoising(gray, h=10)

            # 3. Nhận diện văn bản
            reader = cls.get_reader()
            # detail=0 để chỉ lấy chuỗi văn bản, bỏ qua tọa độ khung hình
            results = reader.readtext(denoised, detail=0)

            # 4. Hậu xử lý chuỗi
            extracted_text = " ".join(results).strip()

            if not extracted_text:
                raise OCRError(detail="OCR không tìm thấy ký tự nào trong ảnh.")

            # Tự động sửa một số lỗi ký tự toán học phổ biến của OCR
            clean_text = cls._clean_math_text(extracted_text)

            return clean_text

        except Exception as e:
            raise OCRError(detail=f"Lỗi hệ thống OCR (EasyOCR): {str(e)}")

    @staticmethod
    def _clean_math_text(text: str) -> str:
        """Làm sạch các ký tự lạ thường gặp khi quét toán học"""
        replacements = {
            '—': '-',
            '–': '-',
            '×': '*',
            '÷': '/',
            ':': '/',
            'x2': 'x^2', # Lỗi phổ biến: số mũ biến thành số thường
            'x3': 'x^3',
            'o': '0',   # Nhầm chữ o với số 0
            '|': '',    # Lọc các vạch nhiễu
        }
        for old, new in replacements.items():
            text = text.replace(old, new)
        return text