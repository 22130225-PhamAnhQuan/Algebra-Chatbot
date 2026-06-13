# Sử dụng Python phiên bản 3.10 dạng slim để dung lượng container nhẹ nhất
FROM python:3.10-slim

# Thiết lập thư mục làm việc bên trong container
WORKDIR /app

# Cài đặt các thư viện hệ thống cần thiết cho Pillow và Pix2Tex xử lý ảnh
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Sao chép file danh sách thư viện vào container trước để tận dụng cache của Docker
COPY requirements.txt .

# Cài đặt các thư viện Python (FastAPI, SymPy, Pix2Tex, Pillow, SQLAlchemy...)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Sao chép toàn bộ mã nguồn của em vào thư mục /app trong container
COPY . .

# Mở cổng 8000 để Frontend Flutter có thể kết nối vào qua REST API
EXPOSE 8000

# Lệnh chạy Backend FastAPI bằng Uvicorn khi container khởi động
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]