from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
import asyncio

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
print(MONGO_URI)

client = AsyncIOMotorClient(MONGO_URI)
db = client["chat_record"]