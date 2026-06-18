# 📱 Phát triển ứng dụng di động chatbot hỗ trợ giải bài tập Đại Số cho học sinh trung học cơ sở

[![Framework: Flutter](https://img.shields.io/badge/Frontend-Flutter-%2302569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Backend: FastAPI](https://img.shields.io/badge/Backend-FastAPI-%23009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Database: PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-%234169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![AI Model: Phi--3%20Mini](https://img.shields.io/badge/AI%20Model-Phi--3%20Mini-%230078D4?logo=microsoft&logoColor=white)](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct)
[![OCR: Pix2Tex](https://img.shields.io/badge/OCR-Pix2Tex%20%28LatexOCR%29-%23FF6F61)](https://github.com/lukas-blecher/LaTeX-OCR)

Dự án tiểu luận tốt nghiệp: **"Phát triển ứng dụng di động chatbot hỗ trợ giải bài tập Đại Số cho học sinh trung học cơ sở"** tại Trường Đại học Nông Lâm TP.HCM - Khoa Công nghệ thông tin.

Hệ thống cung cấp một giải pháp **Gia sư Toán học thông minh (Hybrid Math Engine)** tích hợp trên nền tảng di động dưới dạng Chatbot tương tác tự nhiên. Ứng dụng kết hợp sức mạnh tính toán hình thức chính xác tuyệt đối của lõi toán học cơ sở (**SymPy**) và khả năng suy luận lập luận của mô hình ngôn ngữ nhỏ (**Phi-3 Mini**), hỗ trợ học sinh THCS tự học môn Đại số một cách trực quan, sinh động.

---

## 🚀 Tính năng cốt lõi (Core Features)

- **Nhập liệu đa phương thức (Multi-modal Input):** Học sinh nhập đề bài Đại số trực tiếp từ bàn phím ký tự hoặc chụp ảnh/tải ảnh đề bài lên hệ thống.
- **Mắt thần Công thức Toán học (Pix2Tex OCR Pipeline):** Tích hợp mô hình học sâu chuyên dụng `Pix2Tex (LatexOCR)` tự động trích xuất cấu trúc hình ảnh công thức toán toán phức tạp thành chuỗi ký tự LaTeX sạch sẽ, được tối ưu hóa bằng Regex để loại bỏ nhiễu định dạng.
- **Lõi điều phối toán học lai (Hybrid Math Engine):**
  - **Luồng Đại số Hình thức (SymPy Solver):** Giải quyết chính xác tuyệt đối 100% các bài toán cơ bản theo quy tắc cố định (Phương trình bậc 2, hệ phương trình, rút gọn đa thức) và sinh lời giải theo chuẩn cấu trúc sư phạm SGK THCS Việt Nam.
  - **Luồng Toán đố Lập luận (AI Phi-3 Mini Engine):** Đọc hiểu ngữ nghĩa các bài toán đố bằng lời văn phức tạp, tự động lập phương trình và sinh lời giải thích từng bước bằng tiếng Việt thông qua kỹ thuật Prompt Engineering.
  - **Cơ chế Fallback thông minh:** Tự động chuyển hướng xử lý sang AI khi lõi toán học SymPy gặp các bài toán vượt biên thuật toán, đảm bảo luồng trải nghiệm không bị ngắt quãng.
- **Chatbot Nhận thức Ngữ cảnh (Context-Aware Chatbot):** Hỗ trợ trò chuyện đa lượt (Multi-turn conversation). Hệ thống tự động khôi phục ngữ cảnh (Đề bài gốc + Lời giải hiện tại + Lịch sử tin nhắn) để AI đóng vai gia sư giải thích sâu sắc bất cứ bước giải nào học sinh chưa hiểu.
- **Đồ thị Hàm số trực quan:** Tự động tính toán bảng giá trị và vẽ đồ thị (đường thẳng, Parabol), đóng gói truyền dữ liệu dạng ảnh mã hóa Base64 về cho Client hiển thị.
- **Phân hệ Quản trị (Admin Panel CRUD):** Admin quản lý cấu trúc cây giáo trình bám sát sách Kết nối tri thức, theo dõi AI Logs và lịch sử toàn hệ thống.
- **Bảo mật & Phân quyền:** Xác thực nghiêm ngặt bằng cơ chế mã hóa Token JWT (JSON Web Tokens).

---

## 🏗️ Kiến trúc Hệ thống (Architecture Overview)

Hệ thống được tổ chức theo kiến trúc phân tầng (Layered Architecture) nhằm đảm bảo tính Clean Code và dễ mở rộng:

<img width="915" height="333" alt="image" src="https://github.com/user-attachments/assets/b30c23d4-dd07-43f7-9dfc-160b3f4545a6" />

## 🛠️ Công nghệ Sử dụng (Tech Stack)
### Frontend (Mobile App)
- Nền tảng: Flutter (Dart) - Đa nền tảng (iOS & Android).
- Kết nối HTTP: Dio (Quản lý Request, Interceptor, Upload Multipart file).
- Hiển thị Toán học: flutter_math_fork (Render biểu thức LaTeX động mượt mà).
- Phần cứng: image_picker (Tương tác Camera thiết bị và Thư viện ảnh).

### Backend (Server API)
- Framework: FastAPI (Python) - Hiệu năng xử lý bất đồng bộ cao (async/await).
- IDE Khuyên dùng: IntelliJ IDEA.
- ORM: SQLAlchemy phối hợp với Alembic để quản lý Migration.
- Tính toán Toán học: SymPy (Symbolic Mathematics).
- Thị giác Máy tính (OCR): Pix2Tex (LatexOCR) deep learning model.
- AI Serving: Ollama chạy cục bộ (Local Model Deployment).
- Mã hóa & Bảo mật: Passlib (Băm mật khẩu Bcrypt), PyJWT (Xác thực phân quyền).

### Database & DevOps
Cơ sở dữ liệu: PostgreSQL (Lưu trữ quan hệ toàn vẹn ACID).
Đóng gói ứng dụng: Docker & Docker Compose.

## 🔧 Hướng dẫn Cài đặt & Triển khai (Installation & Deployment)
### 📌 Điều kiện tiên quyết (Prerequisites)
Đã cài đặt Python 3.10+, Flutter SDK, Docker & Docker Compose.
Đã tải và cài đặt Ollama trên máy chủ local.
#### 1. Cấu hình Mô hình AI (Ollama)
Khởi động Ollama và kéo mô hình Phi-3 Mini về máy:
ollama run phi3:mini

#### 2. Triển khai Backend FastAPI (Local Development)
- Mở project bằng IntelliJ IDEA, mở terminal (chỉ định thư mục backend) và khởi tạo môi trường ảo:
cd backend
python -m venv venv
- Trên IOS/Linux: source venv/bin/activate
- Trên Windows dùng: venv\Scripts\activate

- Cài đặt các thư viện phụ thuộc:
pip install -r requirements.txt
- Cấu hình file .env tại thư mục gốc backend:
  - DATABASE_URL=postgresql://user:password@localhost:5432/math_tutor
  - OLLAMA_URL=http://localhost:11434
  - SECRET_KEY=your_super_secret_jwt_key
  - ALGORITHM=HS256
- Khởi chạy Server FastAPI:
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

#### 3. Triển khai Nhanh bằng Docker Compose (Production Setup)
Hệ thống hỗ trợ đóng gói container toàn bộ Backend và Database chỉ bằng một lệnh duy nhất:

docker-compose up --build -d
4. Triển khai Frontend Ứng dụng di động (Flutter)
- Lưu ý: Mặc định mã nguồn chính và các ca kiểm thử ổn định được lưu hành tại nhánh phát triển testcase_anhtuan.

- Chuyển sang nhánh làm việc chính xác:
git checkout testcase_anhtuan
- Tải các Packages phụ thuộc:
flutter pub get
- Cấu hình IP Endpoint trỏ về Backend trong file lib/services/api_service.dart:
  - Nếu chạy máy ảo Android Emulator: sử dụng http://10.0.2.2:8000
  - Nếu chạy thiết bị thật: Sử dụng IP cục bộ của máy tính của bạn (VD: http://192.168.1.X:8000).
- Khởi chạy ứng dụng:
flutter run.

## 🧑‍💻 Thông tin Phát triển (Contributors)
- Sinh viên thực hiện: Phạm Anh Quân
- Mã số sinh viên (MSSV): 22130225
- Lớp: DH22DTA
- Giảng viên hướng dẫn: Thạc sĩ Nguyễn Đức Công Song
- Đơn vị công tác: Khoa Công nghệ Thông tin - Trường Đại học Nông Lâm TP.HCM.
