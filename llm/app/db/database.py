from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import MONGO_URI, DB_NAME
from pymongo import MongoClient

client = AsyncIOMotorClient(MONGO_URI)

db = client[DB_NAME]

def get_database():
    """
    DB의 정보를 긁어오는데 쓰는 함수
    """
    mongo_uri = MONGO_URI
    db_name = DB_NAME
    client = MongoClient(mongo_uri) # client = MongoDB서버와 연결하는 객체
    return client[db_name] # 특정 DB를 선택하고 반환