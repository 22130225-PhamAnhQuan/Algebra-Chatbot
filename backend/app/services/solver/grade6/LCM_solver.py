from sympy import factorint, lcm


class LcmSolver:

    def solve(self, content: str):

        steps = []

        try:
            parts = content.replace(",", " ").split()
            a = int(parts[0])
            b = int(parts[1])
        except (ValueError, IndexError):
            return {
                "result": "Lỗi định dạng",
                "steps": ["Định dạng: 'a b' hoặc 'a, b'"]
            }

        steps.append(
            f"Tìm BCNN({a},{b})"
        )

        result = lcm(a, b)

        steps.append(
            f"BCNN({a},{b}) = {result}"
        )

        return {
            "result": str(result),
            "steps": steps
        }
