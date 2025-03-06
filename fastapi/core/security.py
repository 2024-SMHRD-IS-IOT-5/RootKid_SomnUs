# JWT, 암호화 관련 유틸
from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import JWSError, jwt
from core.config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    # 비밀번호 bcrypt 해싱
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password:str) ->bool:
    # 비밀번호 검증
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    # JWT 액세스 토큰 생성
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    # JWT 토큰 해독
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWSError:
        return None