from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Any
from datetime import datetime, timezone, timedelta
from pymongo import MongoClient

from app.services.report.daily_report_service import daily_report_process
from app.services.report.weekly_report_service import weekly_report_process
from app.services.report.monthly_report_service import monthly_report_process
from app.db.report_repository import save_report


router = APIRouter()

class ReportResponse(BaseModel):
    response: str

class SleepDataModel(BaseModel):
    sleep_data: dict[str, Any]
    

    
@router.post("")
async def write_report(sleep_data:dict):
    """ 메인 서버에서 받은 수면 데이터를 받아서 리포트 생성"""
    print("=======리포트 작성 시작!========")
    
    id = sleep_data["id"]
    type = sleep_data["aggregation_type"]
    
    KST = timezone(timedelta(hours=9))
    time = datetime.now(KST)
    
    if type ==  "daily":
        result = await daily_report_process(sleep_data)
        date = sleep_data["date"]
        
    elif type == "weekly":
        result = await weekly_report_process(sleep_data)
        date = sleep_data["week_number"]
        # print(len(result))
        
    elif type == "monthly":
        result = await monthly_report_process(sleep_data)
        date = sleep_data["month_number"]
        
    await save_report(id=id, date=date, comment=result, timestamp=time, type=type)
    
    return {f"message" : "{type} 리포트 작성 완료", "result": {"chatbot_response": result}}