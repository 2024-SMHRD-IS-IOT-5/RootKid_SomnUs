# DB 연결 설정

from motor.motor_asyncio import AsyncIOMotorClient
from core.config import MONGO_URI, DB_NAME

client = AsyncIOMotorClient(MONGO_URI)

db = client[DB_NAME]  # 사용할 데이터베이스명
users_collection = db["member"]  # 사용자(학생) 테이블 (컬렉션)
parents_collection = db["parents"]  # 학부모 정보 저장

