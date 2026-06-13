from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import desc, func

from app.db.database import get_db
from app.models.chapter import Chapter
from app.models.grade import Grade
from app.models.lesson import Lesson
from app.models.user import User
from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History
from app.schemas.curriculum import LessonDetailResponse
from app.services.curriculum_service import get_lesson_by_id

try:
    from app.models.formula import Formula
    from app.models.ai_log import AILog
except ImportError:
    from app.db.database import Base

    Formula = getattr(Base, '_decl_class_registry', {}).get('Formula')
    AILog = getattr(Base, '_decl_class_registry', {}).get('AILog')

from app.core.dependencies import get_current_admin

router = APIRouter(
    prefix="/admin",
    tags=["Admin Mobile Management"]
)

@router.get("/dashboard-stats")
def admin_get_dashboard_statistics(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    total_students = (
        db.query(User)
        .filter(User.role == "USER")
        .count()
    )

    total_problems = db.query(Problem).count()

    total_lessons = db.query(Lesson).count()

    ai_solved_count = (
        db.query(Solution)
        .filter(Solution.model == "ai")
        .count()
    )

    sympy_solved_count = (
        db.query(Solution)
        .filter(Solution.model != "ai")
        .count()
    )

    type_stats = (
        db.query(
            Solution.problem_type,
            func.count(Solution.id)
        )
        .group_by(Solution.problem_type)
        .all()
    )

    problem_types_distribution = {
        p_type: count
        for p_type, count in type_stats
        if p_type
    }

    ai_performance = {
        "total_tokens_used": 0,
        "avg_latency_ms": 0.0
    }

    if AILog is not None:
        total_tokens = (
            db.query(
                func.sum(AILog.tokens_used)
            ).scalar()
            or 0
        )

        avg_latency = (
            db.query(
                func.avg(AILog.latency_ms)
            ).scalar()
            or 0
        )

        ai_performance = {
            "total_tokens_used": int(total_tokens),
            "avg_latency_ms": round(
                float(avg_latency),
                2
            )
        }

    return {
        "success": True,
        "data": {
            "overview": {
                "total_students": total_students,
                "total_problems_submitted": total_problems,

                "total_lessons": total_lessons
            },

            "solver_distribution": {
                "ai_assistant": ai_solved_count,
                "rule_based_sympy": sympy_solved_count
            },

            "problem_types_breakdown":
                problem_types_distribution,

            "ai_engine_performance":
                ai_performance
        }
    }

@router.get("/users")
def admin_get_all_users(
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    users = db.query(User).filter(User.role == 'USER').order_by(User.id).all()
    return {
        "success": True,
        "data": [
            {
                "id": u.id,
                "email": u.email,
                "name": u.name,
                "is_active": u.is_active,
                "created_at": u.created_at
            } for u in users
        ]
    }


@router.put("/users/{user_id}/toggle-status")
def admin_toggle_user_status(
        user_id: int,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    user = db.query(User).filter(User.id == user_id, User.role == 'USER').first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Không tìm thấy tài khoản học sinh cần xử lý"
        )

    user.is_active = not user.is_active
    db.commit()
    db.refresh(user)

    status_msg = "Mở khóa" if user.is_active else "Khóa"
    return {
        "success": True,
        "message": f"Đã {status_msg} tài khoản {user.email} thành công!",
        "is_active": user.is_active
    }

@router.get("/ai-logs")
def admin_get_ai_logs(
        limit: int = 50,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    if AILog is None:
        raise HTTPException(status_code=500, detail="Hệ thống chưa cấu hình ORM Model cho bảng ai_logs")

    logs = db.query(AILog).order_by(desc(AILog.created_at)).limit(limit).all()
    return {
        "success": True,
        "data": [
            {
                "id": log.id,
                "user_id": log.user_id,
                "user_name": log.name,
                "problem_id": log.problem_id,
                "input": log.input,
                "output": log.output,
                "model": log.model,
                "latency_ms": log.latency_ms,
                "status": log.status,
                "tokens_used": log.tokens_used,
                "created_at": log.created_at
            } for log in logs
        ]
    }

@router.get("/histories")
def admin_get_solve_histories(
        limit: int = 50,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    histories = db.query(History).order_by(desc(History.created_at)).limit(limit).all()

    result_list = []
    for h in histories:
        user = db.query(User).filter(User.id == h.user_id).first()
        prob = db.query(Problem).filter(Problem.id == h.problem_id).first()
        sol = db.query(Solution).filter(Solution.id == h.solution_id).first()

        result_list.append({
            "history_id": h.id,
            "created_at": h.created_at,
            "user": {
                "id": user.id if user else None,
                "name": user.name if user else "N/A",
                "email": user.email if user else "N/A"
            } if user else None,
            "problem": {
                "id": prob.id if prob else None,
                "content": prob.content if prob else "Nội dung bị xóa",
                "input_type": prob.input_type if prob else "text",
                "image_url": prob.image_url if prob else None
            } if prob else None,
            "solution": {
                "id": sol.id if sol else None,
                "result": sol.result if sol else "N/A",
                "problem_type": sol.problem_type if sol else "N/A",
                "model": sol.model if sol else "N/A"
            } if sol else None
        })

    return {
        "success": True,
        "data": result_list
    }

@router.get("/grades")
def admin_get_grades(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    grades = (
        db.query(Grade)
        .order_by(Grade.id)
        .all()
    )

    return {
        "success": True,
        "data": [
            {
                "id": grade.id,
                "name": grade.name
            }
            for grade in grades
        ]
    }

@router.get("/grades/{grade_id}/chapters")
def admin_get_chapters(
    grade_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    chapters = (
        db.query(Chapter)
        .filter(
            Chapter.grade_id == grade_id
        )
        .order_by(
            Chapter.chapter_number
        )
        .all()
    )

    return {
        "success": True,
        "data": [
            {
                "id": chapter.id,
                "grade_id": chapter.grade_id,
                "chapter_number": chapter.chapter_number,
                "title": chapter.title
            }
            for chapter in chapters
        ]
    }

@router.get("/chapters/{chapter_id}/lessons")
def admin_get_lessons(
    chapter_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    lessons = (
        db.query(Lesson)
        .filter(
            Lesson.chapter_id == chapter_id
        )
        .order_by(
            Lesson.lesson_number
        )
        .all()
    )

    return {
        "success": True,
        "data": [
            {
                "id": lesson.id,
                "chapter_id": lesson.chapter_id,
                "lesson_number": lesson.lesson_number,
                "title": lesson.title,
                "theory": lesson.theory,
                "formula": lesson.formula,
                "example": lesson.example
            }
            for lesson in lessons
        ]
    }

@router.post("/lessons")
def admin_create_lesson(
    chapter_id: int,
    lesson_number: int,
    title: str,
    theory: str = "",
    formula: str = "",
    example: str = "",
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    lesson = Lesson(
        chapter_id=chapter_id,
        lesson_number=lesson_number,
        title=title,
        theory=theory,
        formula=formula,
        example=example
    )

    db.add(lesson)
    db.commit()
    db.refresh(lesson)

    return {
        "success": True,
        "message": "Tạo bài học thành công",
        "data": {
            "id": lesson.id
        }
    }

@router.get(
    "/lessons/{lesson_id}",
    response_model=LessonDetailResponse
)
def get_lesson_detail(
    lesson_id: int,
    db: Session = Depends(get_db)
):

    lesson = get_lesson_by_id(
        db,
        lesson_id
    )

    if lesson is None:
        raise HTTPException(
            status_code=404,
            detail="Lesson not found"
        )

    return lesson

@router.put("/lessons/{lesson_id}")
def admin_update_lesson(
    lesson_id: int,
    lesson_number: int | None = None,
    title: str | None = None,
    theory: str | None = None,
    formula: str | None = None,
    example: str | None = None,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    lesson = (
        db.query(Lesson)
        .filter(
            Lesson.id == lesson_id
        )
        .first()
    )

    if not lesson:
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy bài học"
        )

    if lesson_number is not None:
        lesson.lesson_number = lesson_number

    if title is not None:
        lesson.title = title

    if theory is not None:
        lesson.theory = theory

    if formula is not None:
        lesson.formula = formula

    if example is not None:
        lesson.example = example

    db.commit()
    db.refresh(lesson)

    return {
        "success": True,
        "message": "Cập nhật bài học thành công"
    }

@router.delete("/lessons/{lesson_id}")
def admin_delete_lesson(
    lesson_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    lesson = (
        db.query(Lesson)
        .filter(
            Lesson.id == lesson_id
        )
        .first()
    )

    if not lesson:
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy bài học"
        )

    db.delete(lesson)
    db.commit()

    return {
        "success": True,
        "message": "Xóa bài học thành công"
    }