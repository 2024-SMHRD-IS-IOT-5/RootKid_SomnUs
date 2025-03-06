# app/api/report.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
from app.core.config import FASTAPI_SERVER_URL

router = APIRouter()

class ReportResponse(BaseModel):
    response: str

# -> str : 어노테이션 : 함수가 반환할 타입 지정, 가독성 높이고 타입검사 할때 도움된대.
async def send_report(report_type: str) -> str:
    # 각 리포트 유형에 맞는 응답 메시지 생성
    response_text = f"{report_type} 리포트 요청에 대한 응답입니다!"
    payload = {"response": response_text}
    try:
        # 메인 서버의 /chatbot/receive-report 엔드포인트로 응답 전송
        async with httpx.AsyncClient() as client:
            res = await client.post(f"{FASTAPI_SERVER_URL}/chatbot/receive-report", json=payload)
            res.raise_for_status()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"응답 전송 실패: {str(e)}")
    return response_text

# @router.post("chatbot/daily-report", response_model=ReportResponse)
# async def daily_report():
#     result = await send_report("일간")
#     return ReportResponse(response=result)

# @router.post("chatbot/weekly-report", response_model=ReportResponse)
# async def weekly_report():
#     result = await send_report("주간")
#     return ReportResponse(response=result)

# @router.post("chatbot/monthly-report", response_model=ReportResponse)
# async def monthly_report():
#     result = await send_report("월간")
#     return ReportResponse(response=result)

@router.post("chatbot/{report_type}-report", response_model=ReportResponse)
async def report(report_type: str):
    # report_type이 유효한 값인지 검사합니다.
    valid_types = {"daily": "일간", "weekly": "주간", "monthly": "월간"}
    if report_type not in valid_types:
        raise HTTPException(status_code=400, detail="Invalid report type")

    # report_type에 맞는 값을 send_report 함수에 전달합니다.
    result = await send_report(valid_types[report_type])
    return ReportResponse(response=result)
