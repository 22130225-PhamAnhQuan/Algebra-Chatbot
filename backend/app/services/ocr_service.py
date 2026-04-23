import pytesseract
from PIL import Image
import io
from app.core.exceptions import OCRError


class OcrService:
    @classmethod
    async def extract_text_from_image(cls, image_bytes: bytes) -> str:
        """
        Sử dụng Tesseract OCR để nhận dạng đề bài từ ảnh chụp.
        """
        try:
            # 1. Chuyển đổi mảng byte nhận từ Flutter thành đối tượng Image (Pillow)
            image = Image.open(io.BytesIO(image_bytes))

            # 2. Tiền xử lý nhẹ (optional): Chuyển về ảnh xám để Tesseract đọc chuẩn hơn
            image = image.convert('L')

            # 3. Cấu hình Tesseract:
            # --oem 3: Sử dụng engine mặc định (LSTM)
            # --psm 6: Coi toàn bộ ảnh là một khối văn bản duy nhất
            custom_config = r'--oem 3 --psm 6 -c tessedit_char_whitelist=0123456789xyz+-*/=()^., '

            extracted_text = pytesseract.image_to_string(image, config=custom_config)

            # 4. Kiểm tra nếu không đọc được gì thì văng lỗi Custom Exception đã viết
            if not extracted_text.strip():
                raise OCRError()

            return extracted_text.strip()

        except Exception as e:
            # Nếu có lỗi hệ thống (chưa cài Tesseract engine), báo lỗi rõ ràng
            raise OCRError(detail=f"Lỗi kỹ thuật OCR: {str(e)}")