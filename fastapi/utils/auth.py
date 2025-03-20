from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from core.config import SECRET_KEY, ALGORITHM
from models.auth_models import TokenData

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def get_current_user(token: str = Depends(oauth2_scheme)) -> TokenData:
    """JWT 토큰에서 사용자 ID와 role을 추출하는 함수"""
    credentials_exception = HTTPException(
        status_code=401,
        detail="인증 정보가 올바르지 않습니다.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")  # JWT에서 user_id 가져오기
        if user_id is None:
            raise credentials_exception
        
        role: str = payload.get("role")
        if role is None:
            raise credentials_exception
        
        student_id = payload.get("student_id") if role == "parent" else None
        
        return TokenData(user_id=user_id, role=role, student_id=student_id) # TokenData 객체로 변환
    except JWTError:
        raise credentials_exception
