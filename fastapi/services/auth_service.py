# 사용자 인증 및 권한 관리를 담당 비즈니스 로직 계층
# 실제 인증 로직 수행(로그인, 회원가입, 토큰 발급 등)
# DB와 직접 통신

# from datetime import datetime, timedelta
# from typing import Optional
# from jose import JWTError, jwt
# from passlib.context import CryptContext
# from config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES
# from models import User
# from database import users_collection  # MongoDB 연동

# # 비밀번호 해싱을 위한 설정
# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# # JWT 토큰 생성
# def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
#     to_encode = data.copy()
#     expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
#     to_encode.update({"exp": expire})
#     return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# # JWT 토큰 검증
# def decode_token(token: str):
#     try:
#         payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
#         return payload
#     except JWTError:
#         return None

# # 비밀번호 해싱
# def hash_password(password: str) -> str:
#     return pwd_context.hash(password)

# # 비밀번호 검증
# def verify_password(plain_password: str, hashed_password: str) -> bool:
#     return pwd_context.verify(plain_password, hashed_password)

# # 사용자 회원가입
# async def register_user(username: str, email: str, password: str):
#     existing_user = await users_collection.find_one({"email": email})
#     if existing_user:
#         return None  # 이메일 중복 처리

#     hashed_pw = hash_password(password)
#     new_user = {"username": username, "email": email, "password": hashed_pw}
#     await users_collection.insert_one(new_user)
#     return new_user

# # 사용자 로그인 (ID/PW 검증)
# async def authenticate_user(email: str, password: str):
#     user = await users_collection.find_one({"email": email})
#     if not user or not verify_password(password, user["password"]):
#         return None  # 로그인 실패
#     return user
