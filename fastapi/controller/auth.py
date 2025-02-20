# 로그인/회원가입
# FastAPI의 엔드포인트 auth_service.py의 함수를 호출

# from fastapi import APIRouter, HTTPException, Depends
# from models import UserCreate, UserResponse
# from services.auth_service import register_user, authenticate_user, create_access_token
# from datetime import timedelta

# router = APIRouter(prefix="/auth", tags=["Auth"])

# @router.post("/register", response_model=UserResponse)
# async def register(user: UserCreate):
#     new_user = await register_user(user.username, user.email, user.password)
#     if not new_user:
#         raise HTTPException(status_code=400, detail="Email already exists")
#     return new_user

# @router.post("/login")
# async def login(email: str, password: str):
#     user = await authenticate_user(email, password)
#     if not user:
#         raise HTTPException(status_code=401, detail="Invalid credentials")

#     access_token = create_access_token(data={"sub": user["email"]}, expires_delta=timedelta(minutes=60))
#     return {"access_token": access_token, "token_type": "bearer"}
