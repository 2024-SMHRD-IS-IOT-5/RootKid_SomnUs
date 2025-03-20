# 사용자 인증 및 권한 관리를 담당 비즈니스 로직 계층
# 실제 인증 로직 수행(로그인, 회원가입, 토큰 발급 등)

from fastapi import HTTPException
from core.security import hash_password, verify_password, create_access_token
from core.database import users_collection, parents_collection
from models.auth_models import UserRegister, ParentRegister, UserLogin, TokenResponse
from datetime import timedelta

async def register_user(user: UserRegister):
    """사용자(학생) 회원가입 로직"""
    existing_user = await users_collection.find_one({"id": user.id})
    if existing_user:
        raise HTTPException(status_code=400, detail="이미 존재하는 ID입니다.")

    hashed_password = hash_password(user.password)
    new_user = {"id":user.id, "password":hashed_password, "name":user.name,
                "age":user.age, "weight":user.weight}
    
    await users_collection.insert_one(new_user)
    return {"message": "회원가입 성공"}

async def register_parent(parent: ParentRegister):
    """학부모 회원가입 로직"""
    existing_parent = await parents_collection.find_one({"id": parent.id})
    if existing_parent:
        raise HTTPException(status_code=400, detail="이미 존재하는 학부모 ID입니다.")

    existing_student = await users_collection.find_one({"id": parent.student_id})
    if not existing_student:
        raise HTTPException(status_code=400, detail="학생 ID가 존재하지 않습니다.")

    hashed_password = hash_password(parent.password)

    new_parent = {
        "student_id": parent.student_id,
        "id": parent.id,
        "password": hashed_password,
        "role": "parent"
    }

    await parents_collection.insert_one(new_parent)
    return {"message": "학부모 회원가입 성공"}


async def login_user(user: UserLogin):
    """사용자(학생)/ 학부모 로그인"""
    # 1. 학생 컬랙션에서 찾기
    db_user = await users_collection.find_one({"id": user.id})
    user_type = "user" if db_user else None
    
    # 2. 학생 컬렉션에 없으면 학부모 컬렉션에서 찾기
    if not db_user:
        db_user = await parents_collection.find_one({"id": user.id})
        user_type = "parent" if db_user else None
    
    # 3. 아이디 없거나 불일치
    if not db_user or not verify_password(user.password, db_user["password"]):
        raise HTTPException(status_code=400, detail="아이디 또는 비밀번호가 올바르지 않습니다.")
    
    # 4. 부모의 경우 student_id 추가
    payload = {"sub":user.id , "role":user_type}
    if user_type == "parent":
        payload["student_id"] = db_user.get("student_id")
        
    # 5. JWT 토근 생성
    access_token = create_access_token(
        payload,
        expires_delta=timedelta(hours=1)
        )
    
    print("토큰: ", access_token)
    return TokenResponse(access_token=access_token, token_type="bearer")
