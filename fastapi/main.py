from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controller import auth, chatbot
from config import settings  # 환경 변수 설정 (선택)


# FastAPI 초기화
app = FastAPI(
    title="FastAPI & Flutter Backend",
    description="Flutter 연동용 FastAPI 서버",
    version="1.0.0"
)

#  라우터 등록
app.include_router(auth.router)
app.include_router(chatbot.router)

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 (*), 특정 도메인만 허용하려면 ["http://localhost:3000", "https://myapp.com"]
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용 (GET, POST, PUT, DELETE 등)
    allow_headers=["*"],  # 모든 헤더 허용
)


# ✅ 서버 실행 확인용 API
@app.get("/")
async def root():
    return {"message": "FastAPI 서버 실행 중"}

