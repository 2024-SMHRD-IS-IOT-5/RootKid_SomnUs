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
    """현재 로그인한 클라이언트의 전날 수면 데이터를 조회하여 변환 후 반환"""
    try:
        data = await SleepService.get_daily_sleep_data(current_user.user_id, (datetime.today() - timedelta(days=1)).strftime("%Y-%m-%d"))
        print("일일데이터 :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/sleep-data/calendar")
async def get_sleep_data_calendar(date:str, current_user : TokenData = Depends(get_current_user)):
    """클라이언트가 지정한 일일 데이터를 조회하여 변환 후 반환"""
    try:
        data = await SleepService.get_daily_sleep_data(date, current_user.user_id)
        print("일일데이터 :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/sleep-data/weekly")
async def get_weekly_sleep_data(current_user: TokenData = Depends(get_current_user)):
    """저번 주 수면 데이터 조회"""
    try:
        data = await SleepService.get_weekly_sleep_data(current_user.user_id)
        print("주간데이터 :", data)
        return JSONResponse(content=data, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/sleep-data/monthly")
async def get_monthly_sleep_data(current_user: TokenData = Depends(get_current_user)):
    """저번 달 수면 데이터 조회"""
    try:
        data = await SleepService.get_monthly_sleep_data(current_user.user_id)
        print("월간데이터 :", data)
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
    
