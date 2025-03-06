from fastapi import FastAPI, HTTPException
import httpx
import json
import os
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()
FASTAPI_SERVER_URL = os.getenv("FASTAPI_SERVER_URL")  # FastAPI 서버 URL

app = FastAPI()

@app.post("/chatbot/message")
async def receive_message(data: dict):
    """FastAPI 서버에서 받은 사용자 메시지를 처리하고 응답 반환"""
    message = data.get("message", "")
    if not message:
        raise HTTPException(status_code=400, detail="메시지가 비어있음")

    # 🎯 여기에서 LangChain을 활용한 챗봇 응답 생성 (예제)
    chatbot_response = f"🤖 챗봇 응답: '{message}'에 대한 답변입니다."
    
    return {"response": chatbot_response}

app = FastAPI()

@app.get("/chatbot/daily-report")
async def generate_daily_report():
    """FastAPI 서버에서 요청한 일간 보고서 생성"""
    report = {
        "type": "daily",
        "date": "2024-02-21",
        "summary": "7시간 30분 수면, 양호한 수면 품질",
        "recommendation": "오늘은 10시 이전에 취침하는 것이 좋습니다."
    }
    return {"report": json.dumps(report)}

@app.get("/chatbot/weekly-report")
async def generate_weekly_report():
    """FastAPI 서버에서 요청한 주간 보고서 생성"""
    report = {
        "type": "weekly",
        "week": "2024-W08",
        "summary": "평균 수면 시간: 7시간 10분, 안정적인 수면",
        "recommendation": "주말에도 일정한 기상 시간을 유지하세요."
    }
    return {"report": json.dumps(report)}

@app.get("/chatbot/monthly-report")
async def generate_monthly_report():
    """FastAPI 서버에서 요청한 월간 보고서 생성"""
    report = {
        "type": "monthly",
        "month": "2024-02",
        "summary": "평균 수면 시간: 7시간 15분, 규칙적인 수면 패턴",
        "recommendation": "이번 달은 스트레스 지수를 줄이는 활동을 추천합니다."
    }
    return {"report": json.dumps(report)}

@app.post("/fastapi/report")
async def send_report_to_fastapi(report: dict):
    """FastAPI 서버에 보고서를 자동으로 전송"""
    print(f"📄 FastAPI 서버로 보고서 전송: {report}")
    return {"message": "보고서 전송 완료"}

