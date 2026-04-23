import sympy
import httpx
import json
import re
from app.core.config import OLLAMA_URL
from app.core.prompts import AIPrompts
from app.core.exceptions import AIInferenceError, MathCalculationError

class AISolver:

    @classmethod
    async def call_phi3(cls, prompt: str) -> dict:
        payload = {
            "model": "phi3:mini",
            "prompt": prompt,
            "stream": False,
            "format": "json"
        }
        try:
            async with httpx.AsyncClient(timeout=180.0) as client:  # Tăng timeout lên 100s
                response = await client.post(OLLAMA_URL, json=payload)
                if response.status_code != 200:
                    print(f"Ollama Error Status: {response.status_code}")
                    raise AIInferenceError()

                result = response.json()
                return json.loads(result['response'])
        except httpx.ConnectError:
            print("LỖI: Backend không kết nối được tới Ollama. Kiểm tra OLLAMA_URL!")
            raise AIInferenceError()
        except Exception as e:
            print(f"LỖI HỆ THỐNG: {type(e).__name__} - {e}")
            raise AIInferenceError()

    @classmethod
    def process_math(cls, math_type: str, expression: str):
        try:
            x, y = sympy.symbols('x y')
            # 1. Tiền xử lý: x^2 -> x**2 và 2x -> 2*x
            expr_str = expression.replace('^', '**')
            expr_str = re.sub(r'(\d)([a-zA-Z])', r'\1*\2', expr_str)

            if math_type == "phuong_trinh":
                if '=' in expr_str:
                    lhs, rhs = expr_str.split('=')
                    eq = sympy.Eq(sympy.sympify(lhs), sympy.sympify(rhs))
                    result = sympy.solve(eq, x)
                else:
                    result = sympy.solve(sympy.sympify(expr_str), x)
                return f"Nghiệm chính xác: {result}"

            elif math_type == "rut_gon":
                result = sympy.simplify(expr_str)
                return f"Biểu thức sau khi rút gọn: {result}"

            elif math_type == "he_phuong_trinh":
                # Ví dụ: "x+y=5, x-y=1"
                eqs_input = expr_str.split(',')
                eqs = []
                for e in eqs_input:
                    l, r = e.split('=')
                    eqs.append(sympy.Eq(sympy.sympify(l), sympy.sympify(r)))
                result = sympy.solve(eqs, (x, y))
                return f"Nghiệm của hệ: {result}"

            return "Toán đố hoặc dạng bài cần AI lập luận chi tiết."
        except:
            return "SymPy không giải trực tiếp được, cần AI phân tích logic."

    @classmethod
    async def solve(cls, raw_text: str):
        # Bước 1: Phi-3 phân loại (Router) [cite: 10, 15]
        classify_prompt = AIPrompts.ROUTER_CLASSIFY + f"\nĐề bài: {raw_text}"
        meta = await cls.call_phi3(classify_prompt)

        # Bước 2: SymPy tính toán lõi để đảm bảo độ chính xác [cite: 16, 24]
        sympy_result = cls.process_math(meta.get('type'), meta.get('expression', ''))

        # Bước 3: Phi-3 viết lời giải sư phạm dựa trên kết quả SymPy [cite: 36]
        solve_prompt = AIPrompts.SOLVER_STEP_BY_STEP.format(
            raw_text=raw_text,
            sympy_result=sympy_result
        )
        final_json = await cls.call_phi3(solve_prompt)

        return final_json

    @classmethod
    async def call_phi3_text_only(cls, prompt: str) -> str:
        """Hàm dùng riêng cho Chatbot để lấy văn bản hội thoại bình thường"""
        payload = {
            "model": "phi3:mini",
            "prompt": prompt,
            "stream": False
            # Không ép format: json ở đây
        }
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(OLLAMA_URL, json=payload)
                result = response.json()
                return result['response'].strip()
        except Exception:
            return "Xin lỗi, mình gặp chút trục trặc khi kết nối với não bộ AI."