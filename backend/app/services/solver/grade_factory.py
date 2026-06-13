from app.services.solver.grade6.solve import Grade6Solver
from app.services.solver.grade7.solve import Grade7Solver
from app.services.solver.grade8.solve import Grade8Solver
from app.services.solver.grade9.solve import Grade9Solver


def get_grade_solver(grade_id: int):

    if grade_id == 1:
        return Grade6Solver()

    if grade_id == 2:
        return Grade7Solver()

    if grade_id == 3:
        return Grade8Solver()

    if grade_id == 4:
        return Grade9Solver()

    raise Exception(
        f"Grade {grade_id} not supported"
    )
