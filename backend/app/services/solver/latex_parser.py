from sympy.parsing.latex import (
    parse_latex
)


class LatexParser:

    @staticmethod
    def latex_to_sympy(
        latex_str: str
    ):

        try:

            expr = parse_latex(
                latex_str
            )

            return expr

        except Exception as e:

            raise Exception(
                f"Parse latex failed: {str(e)}"
            )