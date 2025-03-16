from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import MONGO_URI, DB_NAME
from pymongo import MongoClient

client = AsyncIOMotorClient(MONGO_URI)

db = client[DB_NAME]