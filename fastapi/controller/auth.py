# 로그인/회원가입
# FastAPI의 엔드포인트 auth_service.py의 함수를 호출

from fastapi import APIRouter, HTTPException
from services.auth_service import register_user, login_user, register_parent
from models.auth_models import UserLogin, UserRegister, TokenResponse, ParentRegister

router = APIRouter()

@router.post("/register/student")
async def register_student_api(user: UserRegister):
    result = await register_user(user)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result

@router.post("/register/parent")
async def register_parent_api(parent: ParentRegister):
    result = await register_parent(parent)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result

@router.post("/login", response_model=TokenResponse)
async def login(user: UserLogin):
    result = await login_user(user)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
