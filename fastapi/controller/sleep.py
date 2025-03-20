# 수면 데이터 분석
from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
from datetime import datetime, timedelta
from models.auth_models import TokenData
from services.sleep_service import SleepService
from utils.auth import get_current_user

router = APIRouter()
sleep_service = SleepService()

@router.get("/sleep-data")
async def get_sleep_data(current_user : TokenData = Depends(get_current_user)):
    """현재 로그인한 클라이언트의 전날 수면 데이터를 조회하여 변환 후 반환-메인페이지용"""
    try:
        actual_user_id = current_user.student_id if current_user.role == "parent" else current_user.user_id
        data = await SleepService.get_daily_sleep_data(actual_user_id, datetime.today().strftime("%Y-%m-%d"))
        print("Main Data :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/sleep-data/calendar")
async def get_calendar_data(date:str, current_user : TokenData = Depends(get_current_user)):
    """캘린더에 띄울 데이터"""
    try:
        actual_user_id = current_user.student_id if current_user.role == "parent" else current_user.user_id
        data = await SleepService.get_calendar_data(actual_user_id, date)
        print("Calendar Data :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/sleep-data/report")
async def get_sleep_data_report(date:str, current_user : TokenData = Depends(get_current_user)):
    """클라이언트가 지정한 일일 데이터를 조회하여 변환 후 반환"""
    try:
        actual_user_id = current_user.student_id if current_user.role == "parent" else current_user.user_id
        data = await SleepService.get_daily_sleep_data(actual_user_id, date)
        print("Daily Report :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/sleep-data/weekly")
async def get_weekly_sleep_data(date:str, current_user: TokenData = Depends(get_current_user)):
    """주간 수면 데이터 """
    try:
        actual_user_id = current_user.student_id if current_user.role == "parent" else current_user.user_id
        data = await SleepService.get_weekly_sleep_data(actual_user_id, date)
        print("Weekly Report :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/sleep-data/monthly")
async def get_monthly_sleep_data(current_user: TokenData = Depends(get_current_user)):
    """월간 수면 데이터 """
    try:
        actual_user_id = current_user.student_id if current_user.role == "parent" else current_user.user_id
        data = await SleepService.get_monthly_sleep_data(actual_user_id)
        print("<onthly Report :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/sleep-data/save")
async def save_sleep(user_data:dict, current_user: TokenData=Depends(get_current_user)):
    """수면 데이터 저장 API"""
    try:
        await SleepService.save_sleep_data(current_user.user_id, user_data)
        return {"message" : "수면 데이터 저장 성공"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"수면 데이터 저장 실패: {e}")
    
