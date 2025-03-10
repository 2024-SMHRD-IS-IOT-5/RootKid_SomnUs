from datetime import datetime
from core.database import processing_sleep_collection
from core.config import CHATBOT_SERVER_URL
from utils.time import get_monthly_week, format_seconds
import httpx

class SleepService:
    """수면 데이터 처리"""
    
    async def save_sleep_data(user_id, sleep_data):
        """수면 데이터 작성 시 주차(week_number)와 월(month_number) 추가"""
        date_str = sleep_data["date"] # 'yyyy-mm-dd' 형식
        data_obj = datetime.strptime(date_str, "%Y-%m-%d")
        
        # 주차 및 월 정보 추가
        week_number = get_monthly_week(date_str, numeric=True) # 주차를 숫자로 반환
        month_number = f"{data_obj.year}-{data_obj.month:02d}" # 2025-03 형식
        
        sleep_data["week_number"] = f"{month_number}-W{week_number}"
        sleep_data["month_number"] = month_number
        sleep_data["id"] = user_id
        
        await processing_sleep_collection.insert_one(sleep_data)
    
    async def get_weekly_sleep_data(self, user_id: str):
        """주간 평균 수면 데이터 조회"""
        today = datetime.today()
        week_number = get_monthly_week(today.strftime("%Y-%m-%d"))
        return await self._calculate_average({"user_id":user_id, "week_number":week_number })
    
    async def get_monthly_sleep_data(self, user_id: str):
        """월간 평균 수면 데이터 조회"""
        today = datetime.today()
        month_number = f"{today.year}-{today.month:02d}"
        return await self._calculate_average({"user_id":user_id, "month_number":month_number})
    
    async def _calculate_average(self, query):
        """Mongo DB에서 수면 데이터를 조회하고 평균 계산"""
        pipeline = [
            {"$match":query},
            {
                "$group":{
                    "_id": None,
                    "avg_sleep_time" : {"$avg":{"$subtract":["$endDt","$startDt"]}},
                    "avg_deepsleep" : {"$avg":"$deepsleepduration"},
                    "avg_lightsleep" : {"$avg":"$lightsleepduration"},
                    "avg_remsleep" : {"$avg":"$remsleepduration"},
                    "avg_sleep_score" : {"$avg":"$sleep_score"},
                }
            }
        ]

        results = await processing_sleep_collection.aggregate(pipeline).to_list(length=1)
        
        if not results:
            return None
        
        result = results[0]
        return {
            "avg_sleep_time" : format_seconds(result["avg_sleep_time"]),
            "avg_deepsleep" : format_seconds(result["avg_deepsleep"]),
            "avg_lightsleep" : format_seconds(result["avg_lightsleep"]),
            "avg_remsleep" : format_seconds(result["avg_remsleep"]),
            "avg_sleep_score" : round(result["avg_sleep_score"], 2)
        }
        
async def send_sleep_data_to_chatbot(sleep_data: dict):
    """챗봇 서버에 수면 데이터를 전송하는 함수"""
    url = f"{CHATBOT_SERVER_URL}/chatbot/report/daily"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=sleep_data)
            response.raise_for_status()  # HTTP 오류 발생 시 예외 처리
            
            response_json = response.json()  # ✅ 전체 JSON 응답 저장
            chatbot_response = response_json.get("result", {}).get("chatbot_response", "챗봇 응답 오류 발생")
            #chatbot_response = response.json().get("chatbot_response", "챗봇 응답 오류 발생")
            print(f"🚀 챗봇 서버 응답: {chatbot_response}")  # JSON 응답 확인

            return chatbot_response

    except httpx.HTTPStatusError as e:
        return {"error": f"HTTP 오류 발생: {e.response.status_code}"}

    except Exception as e:
        return {"error": f"챗봇 서버 요청 오류: {e}"}