from app.db.database import db
from datetime import datetime
from zoneinfo import ZoneInfo

async def save_chat(userid: str, question: str, response: str):
    chat_data = {
        "userid" : userid,
        "question" : question,
        "response" : response,
        # "timestamp" : datetime.now(ZoneInfo("Asia/Seoul")) #UTC 기준 현재 시간
    }
    insert_result = await db.chat.insert_one(chat_data)
    print("insert 성공! ID: ", insert_result.inserted_id)