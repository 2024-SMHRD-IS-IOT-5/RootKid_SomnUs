# fastapi - 챗봇 http 요청

from fastapi import APIRouter, HTTPException
from services.chatbot_service import chatbot_service
from models.chatbot_model import ChatbotRequest

router = APIRouter()

@router.post("/chatbot/message")
async def chatbot_message(request: ChatbotRequest):
    """사용자가 보낸 메시지를 챗봇 서버에 전달하고 응답을 반환"""
    response = await chatbot_service.send_message(request.message)
    
    if "error" in response:
        raise HTTPException(status_code=500, detail=response["error"])
    
    return {"response": response}

@router.get("/chatbot/{report_type}-report")
async def get_report(report_type: str):
    """챗봇 서버에 보고서 요청 (일간/주간/월간)"""
    if report_type not in ["daily", "weekly", "monthly"]:
        raise HTTPException(status_code=400, detail="잘못된 보고서 타입입니다. (daily, weekly, monthly 중 하나를 사용하세요)")

    report = await chatbot_service.send_report(report_type)
    
    if "error" in report:
        raise HTTPException(status_code=500, detail=report["error"])
    
    return {"report": report}

@router.post("/receive-report")
async def receive_report(report: dict):
    """챗봇 서버에서 보낸 보고서를 FastAPI 서버가 받음"""
    report_type = report.get("type", "unknown")
    print(f"{report_type} 보고서 수신: {report}")
    return {"message":"보고서 저장 완료"}
