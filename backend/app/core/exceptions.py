from fastapi import HTTPException, status

class OCRError(HTTPException):
    def __init__(self, detail: str = "Không thể nhận diện nội dung từ ảnh. Vui lòng chụp rõ và gần hơn."):
        super().__init__(status_code=status.HTTP_400_BAD_REQUEST, detail=detail)

class AIInferenceError(HTTPException):
    def __init__(self, detail: str = "Hệ thống AI đang quá tải hoặc gặp sự cố. Vui lòng thử lại sau."):
        super().__init__(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=detail)

class MathCalculationError(HTTPException):
    def __init__(self, detail: str = "Hệ thống không thể xử lý phép tính này. Có thể biểu thức quá phức tạp hoặc sai định dạng."):
        super().__init__(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=detail)

class InvalidInputError(HTTPException):
    def __init__(self, detail: str = "Đầu vào không hợp lệ. Vui lòng cung cấp văn bản hoặc hình ảnh."):
        super().__init__(status_code=status.HTTP_400_BAD_REQUEST, detail=detail)

class PromptFormatError(HTTPException):
    def __init__(self, detail: str = "Lỗi trích xuất dữ liệu từ AI. Định dạng kết quả không khớp."):
        super().__init__(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=detail)