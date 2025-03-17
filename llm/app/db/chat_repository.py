from app.db.database import db
from datetime import datetime
from zoneinfo import ZoneInfo

async def save_chat(id: str, question: str, response: str, timestamp):
    chat_data = {
        "id" : id,
        "question" : question,
        "response" : response,
        "timestamp" : timestamp
        # "timestamp" : datetime.now(ZoneInfo("Asia/Seoul")) #UTC 기준 현재 시간
    }
    insert_result = await db.chat.insert_one(chat_data)
    print("insert 성공! ID: ", insert_result.inserted_id)