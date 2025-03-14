from app.db.database import db
from datetime import datetime
from zoneinfo import ZoneInfo
from app.db.database import get_database

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
    
    

def get_recent_history(user_id: str):
    """
    주어진 사용자 ID에 해당하는 대화 내역을 조회합니다.
    
    Args:
        user_id (str): 대화 내역을 조회할 사용자의 ID.
    
    Returns:
        list: 최신 메시지부터 순서대로 대화 내역 메시지의 리스트.
    """
    db = get_database()
    collection = db.get_collection("chat")
    
    # 사용자 ID에 해당하는 대화 내역을 타임스탬프 최신순으로 조회
    cursor = collection.find({"id": user_id}).sort("timestamp", -1)
    
    # 메시지들을 리스트로 변환
    history = [
        f"Q: {doc.get('question', '')}\nA: {doc.get('response', '')}"
        for doc in cursor
    ]
    
    return history
