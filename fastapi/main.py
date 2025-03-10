from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controller.websocket_controller import router as websocket_router
from controller.nfc import router as nfc_router
from controller.auth import router as auth_router
from controller.db_test import router as db_test_router
from controller.chatbot import router as chat_bot_router
from controller.sleep import router as sleep_router
#from controller.withings_auth import router as withings_auth_router
import threading
import asyncio
from services.websocket_service import websocket_service

# FastAPI 초기화
app = FastAPI(
    title="FastAPI & Flutter Backend",
    description="FastAPI 서버",
    version="1.0.0"
)

#  라우터 등록
app.include_router(websocket_router)
app.include_router(nfc_router)
app.include_router(auth_router)
app.include_router(db_test_router)
app.include_router(chat_bot_router)
app.include_router(sleep_router)
#app.include_router(withings_auth_router)

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 (*), 특정 도메인만 허용하려면 ["http://localhost:3000", "https://myapp.com"]
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용 (GET, POST, PUT, DELETE 등)
    allow_headers=["*"],  # 모든 헤더 허용
)

async def broadcast(message: str):
    # 메시지 전송
    print(f"Broadcasting: {message}")
    await websocket_service.broadcast_message(message)

def server_input_thread(loop):
    # 별도의 스레드에서 터미널 입력을 받고, 비동기로 broadcast 실행
    while True:
        message = input("input message: ")
        asyncio.run_coroutine_threadsafe(broadcast(message), loop)    

if __name__ == "__main__":
    # 현재 이벤트 루트 가져오기
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    # 입력 처리를 위한 스레드 시작(데몬 스레드로 시작)
    threading.Thread(target=server_input_thread,args=(loop, ),daemon=True).start()
    
    import uvicorn
    config = uvicorn.Config(app, host="0.0.0.0", port=8001, log_level="info")
    server = uvicorn.Server(config)
    loop.run_until_complete(server.serve())
    