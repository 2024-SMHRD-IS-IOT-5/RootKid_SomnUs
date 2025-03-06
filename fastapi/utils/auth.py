from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from core.config import SECRET_KEY, ALGORITHM
from models.auth_models import TokenData

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    """JWT 토큰에서 사용자 ID를 추출하는 함수"""
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
        return TokenData(user_id=user_id) # TokenData 객체로 변환
    except JWTError:
        raise credentials_exception
