# Pydantic 모델 및 DB 스키마 정의
from pydantic import BaseModel

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
    id: str
    password: str
    
class TokenResponse(BaseModel):
    access_token: str
    token_type: str