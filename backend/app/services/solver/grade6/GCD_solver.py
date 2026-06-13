from sympy import factorint, gcd


class GcdSolver:

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

        fa = factorint(a)
        fb = factorint(b)

        def factor_string(factors):
            parts = []

            for p, e in factors.items():

                if e == 1:
                    parts.append(str(p))
                else:
                    parts.append(f"{p}^{e}")

            return " × ".join(parts)

        steps.append(
            f"{a} = {factor_string(fa)}"
        )

        steps.append(
            f"{b} = {factor_string(fb)}"
        )

        gcd_value = gcd(a, b)

        steps.append(
            f"ƯCLN({a},{b}) = {gcd_value}"
        )

        return {
            "result": str(gcd_value),
            "steps": steps
        }
