from sympy import factorint


class PrimeFactorSolver:

    def solve(self, content: str):

        steps = []

        try:
            number = int(content.strip())
        except ValueError:
            return {
                "result": "Lỗi định dạng",
                "steps": ["Nhập số nguyên dương"]
            }

        factors = factorint(number)

        parts = []

        for p, e in factors.items():

            if e == 1:
                parts.append(str(p))
            else:
                parts.append(f"{p}^{e}")

        result = " × ".join(parts)

        steps.append(
            f"{number} = {result}"
        )

        return {
            "result": result,
            "steps": steps
        }
