from fastapi import APIRouter
from app.db.database import db

from app.db.chat_repository import save_chat
from app.services.chat.chat_service import process_chat
from app.test.langgraph import langgraph

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
    

# 테스트용 라우트
@router.get("/chatbot")
async def chat_test():
    print("챗봇 테스트 시작")
    question = "나 이번주는 수면점수 평균이 얼마야?"
    userid = "smhrd"
    usertype = "administrator"
    
    response = process_chat(question=question, user_id = userid, user_type=usertype)
    print(response)
    return {"message":"chatbot testing"}

@router.get("/langgraph")
def langgraph_test():
    print("langgraph 테스트 시작")
    langgraph()
    return "langgraph"