from sympy.parsing.latex import parse_latex

class LatexParser:
    @staticmethod
    def latex_to_sympy(latex_str: str):
        try:
            clean_str = latex_str.replace(r"\left(", "(").replace(r"\right)", ")").strip()
            expr = parse_latex(clean_str)
            return expr
        except Exception as e:
            raise Exception(f"Không thể đọc công thức từ ảnh: {str(e)}")