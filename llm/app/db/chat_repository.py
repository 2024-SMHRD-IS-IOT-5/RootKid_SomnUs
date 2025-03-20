from app.db.database import db
from datetime import datetime, timezone, timedelta

async def save_chat(question: str, response: str):
    
    KST = timezone(timedelta(hours=9))
    time = datetime.now(KST)
    
    chat_data = {
        "question" : question,
        "response" : response,
        "timestamp" : time
    }
    insert_result = await db["chat"].insert_one(chat_data)
    print("insert 성공! ID: ", insert_result.inserted_id)