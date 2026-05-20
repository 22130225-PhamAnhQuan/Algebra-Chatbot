# # app/routers/graph_router.py
#
# from fastapi import APIRouter, Depends, HTTPException
# from sqlalchemy.orm import Session
#
# from app.db.database import get_db
# from app.core.dependencies import get_current_user
# from app.models.user import User
#
# from app.schemas.graph import GraphRequest, GraphResponse
# from app.services.graph_solver_service import GraphSolverService
# import traceback
# router = APIRouter(prefix="/graph", tags=["Graph"])
#
#
# @router.post("", response_model=GraphResponse)
# async def solve_graph_api(
#     req: GraphRequest,
#     db: Session = Depends(get_db),
#     current_user: User = Depends(get_current_user)
# ):
#     try:
#         return GraphSolverService.solve(req=req, db=db, user=current_user)
#
#     except Exception as e:
#         print("❌ ERROR:", e)
#         print(traceback.format_exc())  # << QUAN TRỌNG
#         raise HTTPException(status_code=500, detail=str(e))