from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controller.websocket_controller import router as websocket_router
from controller.device import router as device_router
from controller.auth import router as auth_router
from controller.db_test import router as db_test_router
from controller.chatbot import router as chat_bot_router
from controller.sleep import router as sleep_router
#from controller.withings_auth import router as withings_auth_router
from controller.schedule import router as scheduler_router, init_scheduler, scheduler
import asyncio
from contextlib import asynccontextmanager
from controller.db_test import router as aggregation_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """앱 시작시 스케줄러 초기화"""
    init_scheduler(app)
    yield
    # 앱 종료시 스케줄러 종료
    scheduler.shutdown()

# FastAPI 초기화
app = FastAPI(
    title="FastAPI & Flutter Backend",
    description="FastAPI 서버",
    version="1.0.0",
    lifespan=lifespan
)

#  라우터 등록
app.include_router(websocket_router)
app.include_router(device_router)
app.include_router(auth_router)
app.include_router(db_test_router)
app.include_router(chat_bot_router)
app.include_router(sleep_router)
app.include_router(scheduler_router)
#app.include_router(withings_auth_router)
app.include_router(aggregation_router)

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 (*), 특정 도메인만 허용하려면 ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용 (GET, POST, PUT, DELETE 등)
    allow_headers=["*"],  # 모든 헤더 허용
)

@app.get("/")
async def root():
    return {"message": "FastAPI 서버와 스케줄러가 실행 중입니다."}

if __name__ == "__main__":

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
   
    import uvicorn
    config = uvicorn.Config(app, host="0.0.0.0", port=8001, log_level="info")
    server = uvicorn.Server(config)
    loop.run_until_complete(server.serve())
    