from app.db.chat_repository import save_chat
from app.test.weekly import weekly_data_test
from fastapi import APIRouter
from app.db.database import db


router = APIRouter()

@router.get("/dbtest")
async def dbtest():
    test_data = {
        "question" : "우용씨는 바보인가?",
        "response" : "그렇다!",
        "timestamp" : "지금시각"
    }
    insert_result = await db.chat.insert_one(test_data)
    print ("insert 성공! ID: ", insert_result.inserted_id)
    return "DB 테스트"

@router.get("/weekly")
async def weeklytest():
    result = await weekly_data_test()
    print(result)
    return("weekly data finding")