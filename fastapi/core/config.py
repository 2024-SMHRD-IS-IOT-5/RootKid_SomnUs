# 환경변수 및 설정 파일

import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

# MongoDB 설정
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

# JWT 설정
SECRET_KEY = os.getenv("SECRET_KEY", "mysecret")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))

# FastAPI 설정
# 환경변수에서 문자열 "true"일 경우 True로 변환
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

# 챗봇 서버 url
CHATBOT_SERVER_URL = os.getenv("CHATBOT_SERVER_URL")

