from app.db.chat_repository import save_chat
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
    

# async def insert_test():
#     # 문서 조회
#     collection = db.test

#     # 첫 번째 문서 찾기
#     item = await collection.find_one({})
#     print(item)

# 실행
# if __name__ == "__main__":
#     # motor는 자체 드라이버를 사용해서 asyncio.run()을 하면 충돌남.
#     # 대신 자체 루프인 get_event_loop()를 사용해야 함.
#     try:
#         loop = asyncio.get_event_loop()
#     except RuntimeError:
#         loop = asyncio.new_event_loop()
#         asyncio.set_event_loop(loop)    
#     loop.run_until_complete(insert_test())

