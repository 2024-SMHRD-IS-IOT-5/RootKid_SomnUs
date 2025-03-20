# Pydantic 모델 및 DB 스키마 정의
from pydantic import BaseModel
from typing import Optional

class UserRegister(BaseModel):
    """학생 회원가입 모델"""
    id: str 
    password: str
    name: str
    age: int
    weight: int

class ParentRegister(BaseModel):
    """학부모 회원가입 모델"""
    student_id: str  #  필수 (연결할 학생 ID)
    id: str  
    password: str
        
class UserLogin(BaseModel):
    """로그인 요청 모델"""
    id: str
    password: str
    
class TokenResponse(BaseModel):
    """JWT 토큰 응답 모델"""
    access_token: str
    token_type: str
    
class TokenData(BaseModel):
    """JWT 토큰에서 추출한 사용자 정보 모델"""
    user_id: str  # JWT 토큰에서 가져온 사용자 ID
    role: str # "parent" or "member"
    student_id: Optional[str] = None # 부모 로그인 시 자녀의 아이디
    
class UserInfo(BaseModel):
    """사용자 정보 반환할 때 사용할 모델"""
    id: str
    name: str
    age: int
    weight: int