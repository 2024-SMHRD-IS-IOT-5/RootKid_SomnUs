# 수면 데이터 분석
from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
import json
from datetime import datetime
from core.database import sleep_collection
from models.auth_models import TokenData
from services.sleep_service import SleepService, send_sleep_data_to_chatbot
from utils.time import format_seconds, format_time
from utils.auth import get_current_user

router = APIRouter()
sleep_service = SleepService()

@router.get("/sleep-data")
async def get_sleep_data(current_user : TokenData = Depends(get_current_user)):
    """현재 로그인한 사용자의 최근 수면 데이터를 조회하여 변환 후 반환"""
    user_id = current_user.user_id # TokenData 객체에서 user_id 가져오기
    sleep_data =  await sleep_collection.find_one({"id":user_id}, sort=[("_id",-1)])
     
    if not sleep_data:
        raise HTTPException(status_code=404, detail="수면 데이터가 없습니다.")

    formatted_data = {
        "date": datetime.strptime(sleep_data["date"], "%Y-%m-%d").strftime("%Y년 %m월 %d일"),
        "startDt": format_time(sleep_data["startDt"]),
        "endDt": format_time(sleep_data["endDt"]),
        "sleep_time": format_seconds(sleep_data["endDt"] - sleep_data["startDt"]),
        "deepsleep": format_seconds(sleep_data["deepsleepduration"]),
        "lightsleep": format_seconds(sleep_data["lightsleepduration"]),
        "remsleep": format_seconds(sleep_data["remsleepduration"]),
        "sleep_score": sleep_data["sleep_score"],
        "wakeupcount": sleep_data["wakeupcount"],
        "hr_average": sleep_data["hr_average"],
        "hr_min": sleep_data["hr_min"],
        "hr_max": sleep_data["hr_max"],
        "rr_average": sleep_data["rr_average"],
        "rr_min": sleep_data["rr_min"],
        "rr_max": sleep_data["rr_max"],
        "breathing_disturbances_intensity": sleep_data["breathing_disturbances_intensity"],
        "snoring": sleep_data["snoring"],
        "snoringepisodecount": sleep_data["snoringepisodecount"]
    }
    
    # 챗봇 서버로 데이터 전송
    chatbot_response = await send_sleep_data_to_chatbot(formatted_data)
                                                    
    # JSONResponse 사용 (ensure_ascii=False 적용) -> 한글깨짐 방지
    response_data = json.loads(json.dumps({"sleep_data": formatted_data, "chatbot_response": chatbot_response}, ensure_ascii=False))
    print(response_data)
    return JSONResponse(content=response_data, headers={"Content-Type": "application/json; charset=utf-8"})

@router.post("/sleep-data/save")
async def save_sleep(user_data:dict, current_user: TokenData=Depends(get_current_user)):
    """수면 데이터 저장 API"""
    try:
        await SleepService.save_sleep_data(current_user.user_id, user_data)
        return {"message" : "수면 데이터 저장 성공"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"수면 데이터 저장 실패: {e}")

@router.get("/sleep-data/weekly")
async def get_weekly_sleep_data(current_user: TokenData = Depends(get_current_user)):
    """이번 주 수면 데이터 조회"""
    avg_data = await sleep_service.get_weekly_sleep_data(current_user.user_id)
    
    if not avg_data:
        raise HTTPException(status_code=404, detail="이번 주 수면 데이터가 없습니다")
    
    return avg_data

@router.get("sleep-data/monthly")
async def get_monthly_sleep_data(current_user: TokenData = Depends(get_current_user)):
    """이번 달 수면 데이터 조회"""
    avg_data = await sleep_service.get_monthly_sleep_data(current_user.user_id)
    
    if not avg_data:
        raise HTTPException(status_code=404, detail="이번 달 수면 데이터가 없습니다")
    
    return avg_data