from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from controller.db_test import router as db_test_router
import asyncio

# FastAPI 초기화
app = FastAPI(
    title="FastAPI & Flutter Backend",
    description="FastAPI 서버",
    version="1.0.0"
)

#  라우터 등록
app.include_router(db_test_router)

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 (*), 특정 도메인만 허용하려면 ["http://localhost:3000", "https://myapp.com"]
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용 (GET, POST, PUT, DELETE 등)
    allow_headers=["*"],  # 모든 헤더 허용
)

if __name__ == "__main__":
    # 현재 이벤트 루트 가져오기
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    import uvicorn
    config = uvicorn.Config(app, host="0.0.0.0", port=8005, log_level="info")
    server = uvicorn.Server(config)
    loop.run_until_complete(server.serve())
    