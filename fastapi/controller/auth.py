# 로그인/회원가입
# FastAPI의 엔드포인트 auth_service.py의 함수를 호출

from fastapi import APIRouter, HTTPException, Depends
from services.auth_service import register_user, login_user, register_parent
from models.auth_models import UserLogin, UserRegister, TokenResponse, ParentRegister, UserInfo, TokenData
from utils.auth import get_current_user
from core.database import users_collection

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

@router.get("/user/info", response_model=UserInfo)
async def get_user_info(current_user : TokenData = Depends(get_current_user)):
    """
    현재 로그인한 사용자의 정보를 DB에서 조회하여 비밀번호 제외 후 반환.    
    """
    user = await users_collection.find_one({"id": current_user.user_id}, {"password":0})
    
    if not user:
        raise HTTPException(status_code=404, detail="사용자 정보를 찾을 수 없습니다")
    
    return UserInfo(**user)