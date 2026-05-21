from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import Optional

from app.db.database import get_db
from app.models.user import User
from app.models.problem import Problem
from app.models.solution import Solution
from app.models.history import History

# Khối Import Model an toàn
try:
    from app.models.formula import Formula
    from app.models.ai_log import AILog
except ImportError:
    from app.db.database import Base

    Formula = getattr(Base, '_decl_class_registry', {}).get('Formula')
    AILog = getattr(Base, '_decl_class_registry', {}).get('AILog')

# Người gác cổng bảo mật
from app.core.dependencies import get_current_admin

router = APIRouter(
    prefix="/admin",
    tags=["Admin Mobile Management"]
)


# ==========================================
# 1. THỐNG KÊ HỆ THỐNG (DASHBOARD STATISTICS)
# ==========================================

@router.get("/dashboard-stats")
def admin_get_dashboard_statistics(
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """API Thống kê tổng quan hệ thống dành cho màn hình chính của Admin trên điện thoại"""
    total_students = db.query(User).filter(User.role == 'USER').count()
    total_problems = db.query(Problem).count()
    total_formulas = db.query(Formula).count() if Formula is not None else 0

    ai_solved_count = db.query(Solution).filter(Solution.model == 'ai').count()
    sympy_solved_count = db.query(Solution).filter(Solution.model != 'ai').count()

    type_stats = db.query(
        Solution.problem_type,
        func.count(Solution.id)
    ).group_by(Solution.problem_type).all()

    problem_types_distribution = {p_type: count for p_type, count in type_stats if p_type}

    ai_performance = {"total_tokens_used": 0, "avg_latency_ms": 0.0}
    if AILog is not None:
        total_tokens = db.query(func.sum(AILog.tokens_used)).scalar() or 0
        avg_latency = db.query(func.avg(AILog.latency_ms)).scalar() or 0.0
        ai_performance = {
            "total_tokens_used": int(total_tokens),
            "avg_latency_ms": round(float(avg_latency), 2)
        }

    return {
        "success": True,
        "data": {
            "overview": {
                "total_students": total_students,
                "total_problems_submitted": total_problems,
                "total_formulas_in_curriculum": total_formulas
            },
            "solver_distribution": {
                "ai_assistant": ai_solved_count,
                "rule_based_sympy": sympy_solved_count
            },
            "problem_types_breakdown": problem_types_distribution,
            "ai_engine_performance": ai_performance
        }
    }


# ==========================================
# 2. QUẢN LÝ TÀI KHOẢN (USER MANAGEMENT)
# ==========================================

@router.get("/users")
def admin_get_all_users(
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Lấy danh sách tất cả học sinh có role là USER"""
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
    """Khóa hoặc mở khóa tài khoản của học sinh"""
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


# ==========================================
# 3. QUẢN LÝ LOG HỆ THỐNG AI (AI LOGS MANAGEMENT)
# ==========================================

@router.get("/ai-logs")
def admin_get_ai_logs(
        limit: int = 50,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Lấy danh sách log hoạt động của AI (Bảng ai_logs)"""
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


# ==========================================
# 4. QUẢN LÝ LỊCH SỬ BÀI GIẢI (HISTORY MANAGEMENT)
# ==========================================

@router.get("/histories")
def admin_get_solve_histories(
        limit: int = 50,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Xem lịch sử giải bài, kết nối thông tin giữa Học sinh, Đề bài và Lời giải"""
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


# ==========================================
# 5. QUẢN LÝ GIÁO TRÌNH / CÔNG THỨC TOÁN (FORMULAS MANAGEMENT)
# ==========================================

@router.get("/formulas")
def admin_get_all_formulas(
        grade: Optional[int] = None,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Lấy danh sách công thức, hỗ trợ lọc theo Khối lớp (Toán 6 -> Toán 9)"""
    if Formula is None:
        raise HTTPException(status_code=500, detail="Hệ thống chưa cấu hình ORM Model cho bảng formulas")

    query = db.query(Formula)
    if grade is not None:
        query = query.filter(Formula.grade == grade)

    formulas = query.order_by(Formula.grade, Formula.id).all()
    return {
        "success": True,
        "data": [
            {
                "id": f.id,
                "grade": f.grade,
                "title": f.title,
                "formula": f.formula,
                "explanation": f.explanation,
                "example": f.example,
                "category": f.category,
                "created_at": f.created_at
            } for f in formulas
        ]
    }


@router.get("/formulas/{formula_id}")
def admin_get_formula_detail(
        formula_id: int,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Xem chi tiết một công thức toán học"""
    if Formula is None:
        raise HTTPException(status_code=500, detail="Hệ thống chưa cấu hình ORM Model cho bảng formulas")

    formula_item = db.query(Formula).filter(Formula.id == formula_id).first()
    if not formula_item:
        raise HTTPException(status_code=404, detail="Không tìm thấy công thức")
    return {"success": True, "data": formula_item}


@router.post("/formulas", status_code=status.HTTP_201_CREATED)
def admin_create_formula(
        grade: int,
        title: str,
        formula: str,
        explanation: Optional[str] = None,
        example: Optional[str] = None,
        category: Optional[str] = None,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Admin thêm mới công thức toán học vào giáo trình sách Kết nối tri thức"""
    if Formula is None:
        raise HTTPException(status_code=500, detail="Hệ thống chưa cấu hình ORM Model cho bảng formulas")

    new_formula = Formula(
        grade=grade,
        title=title,
        formula=formula,
        explanation=explanation,
        example=example,
        category=category
    )
    db.add(new_formula)
    db.commit()
    db.refresh(new_formula)
    return {
        "success": True,
        "message": f"Đã thêm công thức thành công vào danh mục Toán lớp {grade}!",
        "data": {
            "id": new_formula.id,
            "title": new_formula.title
        }
    }


@router.put("/formulas/{formula_id}")
def admin_update_formula(
        formula_id: int,
        grade: Optional[int] = None,
        title: Optional[str] = None,
        formula: Optional[str] = None,
        explanation: Optional[str] = None,
        example: Optional[str] = None,
        category: Optional[str] = None,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Admin chỉnh sửa toàn bộ các trường của công thức trong giáo trình KNTT"""
    if Formula is None:
        raise HTTPException(status_code=500, detail="Hệ thống chưa cấu hình ORM Model cho bảng formulas")

    formula_item = db.query(Formula).filter(Formula.id == formula_id).first()
    if not formula_item:
        raise HTTPException(status_code=404, detail="Không tìm thấy công thức để cập nhật")

    if grade is not None: formula_item.grade = grade
    if title is not None: formula_item.title = title
    if formula is not None: formula_item.formula = formula
    if explanation is not None: formula_item.explanation = explanation
    if example is not None: formula_item.example = example
    if category is not None: formula_item.category = category

    db.commit()
    db.refresh(formula_item)
    return {"success": True, "message": "Cập nhật công thức giáo trình thành công!", "data": formula_item}


@router.delete("/formulas/{formula_id}")
def admin_delete_formula(
        formula_id: int,
        db: Session = Depends(get_db),
        admin: User = Depends(get_current_admin)
):
    """Admin xóa một công thức khỏi giáo trình"""
    if Formula is None:
        raise HTTPException(status_code=500, detail="Hệ thống chưa cấu hình ORM Model cho bảng formulas")

    formula_item = db.query(Formula).filter(Formula.id == formula_id).first()
    if not formula_item:
        raise HTTPException(status_code=404, detail="Không tìm thấy công thức cần xóa")

    db.delete(formula_item)
    db.commit()
    return {
        "success": True,
        "message": f"Đã xóa công thức '{formula_item.title}' thành công khỏi kho giáo trình"
    }