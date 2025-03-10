# 수면 데이터 분석
from fastapi import APIRouter, HTTPException, Depends
from core.database import processing_sleep_collection
from datetime import datetime
from utils.auth import get_current_user
from models.auth_models import TokenData

router = APIRouter()

# 초 단위를 "X시간 Y분" 형식으로 변환
def format_seconds(seconds):
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    if hours > 0:
        return f"{hours}시간 {minutes}분" if minutes > 0 else f"{hours}시간"
    return f"{minutes}분"

# Unix timestamp -> HH : MM 형식으로 변환
def format_time(timestamp):
    return datetime.fromtimestamp(timestamp).strftime('%H:%M')

@router.get("/sleep-data")
async def get_sleep_data(current_user : TokenData = Depends(get_current_user)):
    """현재 로그인한 사용자의 최근 수면 데이터를 조회하여 변환 후 반환"""
    user_id = current_user.user_id # TokenData 객체에서 user_id 가져오기
    sleep_data =  await processing_sleep_collection.find_one({"id":user_id}, sort=[("_id",-1)])
 
# @router.get("/sleep-data")
# async def get_sleep_data():
#     """user_id가 'smhrd'인 사용자의 최근 수면 데이터를 조회하여 변환 후 반환"""
#     # 토큰 검증 없이 user_id가 'smhrd'인 데이터만 필터링
#     sleep_data = await processing_sleep_collection.find_one(
#         {"id": "smhrd"},
#         sort=[("_id", -1)]
#     )   
    
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
        "sleep_score": sleep_data["sleep_score"]
    }
    
    return formatted_data