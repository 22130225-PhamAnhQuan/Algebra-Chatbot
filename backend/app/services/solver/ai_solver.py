import sympy
import httpx
import json
import re
from app.core.config import OLLAMA_URL
from app.core.prompts import AIPrompts


class AISolver:
    @classmethod
    async def call_phi3(cls, prompt: str) -> dict:
        # Logic payload giữ nguyên như của bạn
        payload = {
            "model": "phi3:mini",
            "prompt": prompt,
            "stream": False,
            "format": "json",
            "options": {"temperature": 0.1, "num_predict": 512, "num_thread": 4}
        }
        try:
            async with httpx.AsyncClient(timeout=180.0) as client:
                response = await client.post(OLLAMA_URL, json=payload)
                if response.status_code != 200:
                    return {"type": "khong_ro", "expression": ""}

                raw_response = response.json()['response'].strip()
                json_match = re.search(r'\{.*\}', raw_response, re.DOTALL)
                return json.loads(json_match.group()) if json_match else json.loads(raw_response)
        except Exception as e:
            print(f"LỖI AI: {e}")
            return {"type": "khong_ro", "expression": "", "grade": "9"}

    @classmethod
    def process_math(cls, grade: str, math_type: str, expression: str):
        """Hàm điều hướng xử lý SymPy theo khối lớp và dạng toán"""
        try:
            # Khai báo các biến toán học THCS phổ biến
            x, y, z, n = sympy.symbols('x y z n')
            expr_str = expression.replace('^', '**').replace(':', '/')
            # Tự động thêm dấu nhân (ví dụ 2x -> 2*x)
            expr_str = re.sub(r'(\d)([a-zA-Z])', r'\1*\2', expr_str)

            # --- KHỐI LỚP 6 & 7: SỐ HỌC & BIỂU THỨC ĐƠN GIẢN ---
            if grade in ["6", "7"]:
                if math_type == "so_hoc":
                    nums = [int(n) for n in re.findall(r'\d+', expr_str)]
                    return f"ƯCLN: {sympy.gcd(*nums)}, BCNN: {sympy.lcm(*nums)}"
                return f"Kết quả tính toán: {sympy.simplify(expr_str)}"

            # --- KHỐI LỚP 8: HẰNG ĐẲNG THỨC & NHÂN TỬ HÓA ---
            elif grade == "8":
                if math_type == "nhan_tu":
                    return f"Phân tích thành nhân tử: {sympy.factor(expr_str)}"
                return f"Rút gọn biểu thức: {sympy.simplify(sympy.expand(expr_str))}"

            # --- KHỐI LỚP 9: CĂN THỨC, HỆ PT, PT BẬC 2 ---
            else:
                if math_type == "he_phuong_trinh":
                    eqs = [sympy.Eq(sympy.sympify(e.split('=')[0]), sympy.sympify(e.split('=')[1]))
                           for e in expr_str.split(',')]
                    return f"Nghiệm hệ (x, y): {sympy.solve(eqs, (x, y))}"

                # Giải phương trình bậc 2 hoặc chứa căn
                if '=' in expr_str:
                    l, r = expr_str.split('=')
                    res = sympy.solve(sympy.Eq(sympy.sympify(l), sympy.sympify(r)), x)
                else:
                    res = sympy.solve(sympy.sympify(expr_str), x)
                return f"Tập nghiệm x = {res}"

        except Exception as e:
            return f"SymPy không giải trực tiếp được ({e}), AI hãy phân tích logic."

    @classmethod
    async def solve(cls, raw_text: str):
        # Bước 1: Router xác định Lớp (Grade) và Dạng (Type)
        meta = await cls.call_phi3(AIPrompts.ROUTER_CLASSIFY + f"\nĐề: {raw_text}")
        grade = meta.get('grade', '9')
        math_type = meta.get('type', 'phuong_trinh')
        expression = meta.get('expression', '')

        # Bước 2: SymPy tính toán dựa trên khối lớp đã xác định
        sympy_result = cls.process_math(grade, math_type, expression)

        # Bước 3: Viết lời giải theo trình độ sư phạm lớp tương ứng
        solve_prompt = AIPrompts.SOLVER_STEP_BY_STEP.format(
            grade=grade,
            raw_text=raw_text,
            sympy_result=sympy_result
        )
        return await cls.call_phi3(solve_prompt)