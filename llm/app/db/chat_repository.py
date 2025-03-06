from app.db.database import db
from datetime import datetime

async def save_chat(question: str, response: str):
    chat_data = {
        "question" : question,
        "response" : response,
        "timestamp" : datetime.utcnow()
    }
    insert_result = await db.history.insert_one(chat)
    print("insert 성공! ID: ", insert_result.inserted_id)