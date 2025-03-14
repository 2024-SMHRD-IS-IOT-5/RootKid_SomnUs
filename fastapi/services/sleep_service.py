from fastapi import HTTPException
from datetime import datetime, timedelta
from core.database import processing_sleep_collection, sleep_collection
from core.config import CHATBOT_SERVER_URL
from utils.time import get_monthly_week, format_seconds, format_time, format_week_number
import httpx # type: ignore
import json

class SleepService:
    """수면 데이터 처리"""
    
    async def save_sleep_data(self, user_id:str, sleep_data:dict)->None:
        """수면 데이터 작성 시 주차(week_number)와 월(month_number) 추가"""
        date_str = sleep_data["date"] # 'yyyy-mm-dd' 형식
        data_obj = datetime.strptime(date_str, "%Y-%m-%d")
        week_number = get_monthly_week(date_str, numeric=True) # 주차를 숫자로 반환
        month_number = f"{data_obj.year}-{data_obj.month:02d}" # 2025-03 형식
        
        sleep_data["week_number"] = f"{month_number}-W{week_number}"
        sleep_data["month_number"] = month_number
        sleep_data["id"] = user_id
        
        await sleep_collection.insert_one(sleep_data)
    
    @staticmethod
    async def get_daily_sleep_data(user_id: str, date: str) -> dict:
        sleep_data = await sleep_collection.find_one({"id": user_id, "date": date}, sort=[("_id", -1)])
        if not sleep_data:
            raise HTTPException(status_code=404, detail="해당 날짜의 수면 데이터가 없습니다.")
        formatted_data = {
            "date": datetime.strptime(sleep_data["date"], "%Y-%m-%d").strftime("%Y년 %m월 %d일"),
            "startDt": format_time(sleep_data["startDt"]),
            "endDt": format_time(sleep_data["endDt"]),
            "sleep_time": format_seconds(sleep_data["endDt"] - sleep_data["startDt"]),
            "deepsleep": format_seconds(sleep_data["deepsleep_duration"]),
            "lightsleep": format_seconds(sleep_data["lightsleep_duration"]),
            "remsleep": format_seconds(sleep_data["remsleep_duration"]),
            "sleep_score": sleep_data["sleep_score"],
            "wakeupcount": sleep_data["wakeup_count"],
            "hr_average": sleep_data["hr_average"],
            "hr_min": sleep_data["hr_min"],
            "hr_max": sleep_data["hr_max"],
            "rr_average": sleep_data["rr_average"],
            "rr_min": sleep_data["rr_min"],
            "rr_max": sleep_data["rr_max"],
            "breathing_disturbances_intensity": sleep_data["breathing_disturbances_intensity"],
            "snoring": sleep_data["snoring"],
            "snoringepisodecount": sleep_data["snoring_episode_count"],
            "aggregation_type": sleep_data["aggregation_type"]
        }
        
        chatbot_response = await send_sleep_data_to_chatbot(formatted_data)
        response_data = json.loads(json.dumps({"sleep_data": formatted_data, "chatbot_response": chatbot_response}, ensure_ascii=False))
        return response_data
    
    
    @staticmethod
    async def get_weekly_sleep_data(user_id: str) -> dict:
        last_week_date = datetime.today() - timedelta(days=7)
        week_number = get_monthly_week(last_week_date.strftime("%Y-%m-%d"))
        weekly_data = await processing_sleep_collection.find_one(
            {"id": user_id, "week_number": week_number, "aggregation_type": "weekly"},
            sort=[("_id", -1)]
        )
        if not weekly_data:
            raise HTTPException(status_code=404, detail="주간 데이터가 없습니다.")
        formatted_weekly_data = {
            "aggregation_type": weekly_data["aggregation_type"],
            "avg_deep_sleep": format_seconds(weekly_data["avg_deep_sleep"]),
            "avg_light_sleep": format_seconds(weekly_data["avg_light_sleep"]),
            "avg_rem_sleep": format_seconds(weekly_data["avg_rem_sleep"]),
            "avg_sleep_time": format_seconds(weekly_data["avg_sleep_time"]),
            "avg_sleep_score": weekly_data["avg_sleep_score"],
            "week_number": format_week_number(weekly_data["week_number"])
        }
        # 조회한 주간 데이터 외에 해당 주의 월요일부터 일요일까지 데이터도 조회
        monday_date = last_week_date - timedelta(days=last_week_date.weekday())
        day_names = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
        daily_results = {}
        for i in range(7):
            day_date = monday_date + timedelta(days=i)
            day_str = day_date.strftime("%Y-%m-%d")
            daily_record = await sleep_collection.find_one(
                {"id": user_id, "date": day_str},
                sort=[("_id", -1)]
            )
            if daily_record:
                sleep_time_seconds = daily_record["endDt"] - daily_record["startDt"]
                daily_results[f"{day_names[i]}_score"] = daily_record["sleep_score"]
                daily_results[f"{day_names[i]}_time"] = format_seconds(sleep_time_seconds)
            else:
                daily_results[f"{day_names[i]}_score"] = None
                daily_results[f"{day_names[i]}_time"] = None
     
        chatbot_response = await send_sleep_data_to_chatbot(formatted_weekly_data)     
        response_data = json.loads(json.dumps({
            "weekly_data": formatted_weekly_data,
            "daily_data": daily_results,
            "chatbot_response": chatbot_response}, ensure_ascii=False))
        
        return response_data

    @staticmethod
    async def get_monthly_sleep_data(user_id: str) -> dict:
        today = datetime.today()
        first_day_this_month = today.replace(day=1)
        previous_month_last_day = first_day_this_month - timedelta(days=1)
        monthly_number = f"{previous_month_last_day.year}-{previous_month_last_day.month:02d}"
        monthly_data = await processing_sleep_collection.find_one(
            {"id": user_id, "month_number": monthly_number, "aggregation_type": "monthly"},
            sort=[("_id", -1)]
        )
        if not monthly_data:
            raise HTTPException(status_code=404, detail="월간 데이터가 없습니다.")
        formatted_monthly_data = {
            "aggregation_type": monthly_data["aggregation_type"],
            "avg_sleep_time": format_seconds(monthly_data["avg_sleep_time"]),
            "avg_deep_sleep": format_seconds(monthly_data["avg_deep_sleep"]),
            "avg_light_sleep": format_seconds(monthly_data["avg_light_sleep"]),
            "avg_rem_sleep": format_seconds(monthly_data["avg_rem_sleep"]),
            "avg_sleep_score": monthly_data["avg_sleep_score"],
            "month_number": monthly_data["month_number"]
        }
        # 주간 데이터 조회: weekly 데이터 중 week_number가 전 달의 월 정보로 시작하는 문서를 모두 조회
        weekly_cursor = processing_sleep_collection.find({
            "id": user_id,
            "aggregation_type": "weekly",
            "week_number": {"$regex": f"^{monthly_number}-W"}
        })
        weekly_docs = await weekly_cursor.to_list(length=None)
        formatted_weekly_dict = {}
        for doc in weekly_docs:
            week_str = doc.get("week_number", "")
            parts = week_str.split("-W")
            week_num = parts[1] if len(parts) > 1 else week_str
            formatted_weekly_dict[f"{week_num}w_score"] = doc["avg_sleep_score"]
            formatted_weekly_dict[f"{week_num}w_time"] = format_seconds(doc["avg_sleep_time"])
        if "5w_score" not in formatted_weekly_dict:
            formatted_weekly_dict["5w_score"] = 0
        if ("5w_time" not in formatted_weekly_dict) or (formatted_weekly_dict["5w_time"] is None):
            formatted_weekly_dict["5w_time"] = format_seconds(0)
       
        chatbot_response = await send_sleep_data_to_chatbot(formatted_monthly_data)
        response_data = json.loads(json.dumps({
        "monthly_data": formatted_monthly_data,
        "weekly_data": formatted_weekly_dict,
        "chatbot_response": chatbot_response}, ensure_ascii=False))

        return response_data
  
    
    async def _calculate_average(self, query:dict)->dict:
        """Mongo DB에서 수면 데이터를 조회하고 평균 계산"""
        pipeline = [
            {"$match":query},
            {
                "$group":{
                    "_id": None,
                    "avg_sleep_time" : {"$avg":{"$subtract":["$endDt","$startDt"]}},
                    "avg_deep_sleep" : {"$avg":"$deepsleep_duration"},
                    "avg_light_sleep" : {"$avg":"$lightsleep_duration"},
                    "avg_rem_sleep" : {"$avg":"$remsleep_duration"},
                    "avg_sleep_score" : {"$avg":"$sleep_score"},
                }
            }
        ]

        results = await sleep_collection.aggregate(pipeline).to_list(length=1)
        if not results:
            return {}
        
        result = results[0]
        print(result)
        
        return {
            "avg_sleep_time" : int(result["avg_sleep_time"]),
            "avg_deep_sleep" : int(result["avg_deep_sleep"]),
            "avg_light_sleep" : int(result["avg_light_sleep"]),
            "avg_rem_sleep" : int(result["avg_rem_sleep"]),
            "avg_sleep_score" : int(result["avg_sleep_score"]),
        }
        
    async def _calculate_average_month(self, query:dict)->dict:
        """Mongo DB에서 수면 데이터를 조회하고 평균 계산"""
            # query에서 month_number와 user_id를 추출
        month_number = query.get("month_number")
        user_id = query.get("user_id")
    
    # weekly 집계 문서에서 month_number에 해당하는 week_number 필드의 접두사 매칭
        new_query = {
            "id": user_id,
            "aggregation_type": "weekly",
            "week_number": {"$regex": f"^{month_number}-W"}
        }
        
        pipeline = [
            {"$match":new_query},
            {
                "$group":{
                    "_id": None,
                    "avg_sleep_time" : {"$avg":"$avg_sleep_time"},
                    "avg_deep_sleep" : {"$avg":"$avg_deep_sleep"},
                    "avg_light_sleep" : {"$avg":"$avg_light_sleep"},
                    "avg_rem_sleep" : {"$avg":"$avg_rem_sleep"},
                    "avg_sleep_score" : {"$avg":"$avg_sleep_score"},
                }
            }
        ]

        results = await processing_sleep_collection.aggregate(pipeline).to_list(length=1)
        print("results:",results)
        if not results:
            return {}
        
        result = results[0]
        print(result)
        
        return {
            "avg_sleep_time" : int(result["avg_sleep_time"]),
            "avg_deep_sleep" : int(result["avg_deep_sleep"]),
            "avg_light_sleep" : int(result["avg_light_sleep"]),
            "avg_rem_sleep" : int(result["avg_rem_sleep"]),
            "avg_sleep_score" : int(result["avg_sleep_score"]),
        }
            
    async def store_weekly_average(self, user_id:str, week_number:str)->dict:
        """주간 평균 데이터를 processing_sleep 컬렉션에 저장"""
        avg_data = await self._calculate_average({"id": user_id, "week_number": week_number})
        if avg_data:
            aggregated_doc = {
                "id" : user_id,
                "week_number" : week_number,
                "aggregation_type" : "weekly",
                **avg_data
            }
         
            await processing_sleep_collection.update_one(
                {"id": user_id, "week_number": week_number, "aggregation_type": "weekly"},
                {"$set": aggregated_doc},
                upsert=True
            )
        else:
            print('avg_data 없음')
        return avg_data
    
    async def store_monthly_average(self, user_id:str, month_number:str)->dict:
        """월간 평균 데이터를 processing_sleep 컬렉션에 저장"""
        avg_data = await self._calculate_average_month({"user_id": user_id, "month_number": month_number})
        if avg_data:
            aggregated_doc = {
                "id" : user_id,
                "month_number" : month_number,
                "aggregation_type" : "monthly",
                **avg_data
            }
            await processing_sleep_collection.update_one(
                {"id": user_id, "month_number": month_number, "aggregation_type": "monthly"},
                {"$set": aggregated_doc},
                upsert=True
            )
        return avg_data
    
    
async def send_sleep_data_to_chatbot(sleep_data: dict)->dict:
    """챗봇 서버에 수면 데이터를 전송하는 함수"""
    url = f"{CHATBOT_SERVER_URL}/chatbot/report"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=sleep_data)
            response.raise_for_status()  # HTTP 오류 발생 시 예외 처리
            
            response_json = response.json()  # ✅ 전체 JSON 응답 저장
            print(response_json)
            chatbot_response = response_json.get("result", {}).get("chatbot_response", "챗봇 응답 오류 발생")
 
            print(f"🚀 챗봇 서버 응답: {chatbot_response}")  # JSON 응답 확인

            return chatbot_response

    except httpx.HTTPStatusError as e:
        return f"HTTP 오류 발생: {e.response.status_code}"

    except Exception as e:
        return f"챗봇 서버 요청 오류: {e}"
 
 
 
       
# 스케줄러 작업
async def weekly_average_job():
    """매주 일요일 23:59 에 지난 주 데이터 집계하여 저장"""
    today = datetime.today()
    last_week_date = today - timedelta(days=7)
    week_number =  get_monthly_week(last_week_date.strftime("%Y-%m-%d"), numeric=True)
    month_number = f"{last_week_date.year}-{last_week_date.month:02d}"
    week_number_str = f"{month_number}-W{week_number}"
    
    # 해당 주에 해당하는 user_id 목록 추출
    user_ids = await sleep_collection.distinct("id", {"week_number": week_number_str})
    sleep_serivce = SleepService()
    for id in user_ids:
        await sleep_serivce.store_weekly_average(id, week_number_str)
    print(f"Weekly average for {week_number_str} stored.")
    
async def monthly_average_job():
    """매월 1일 00:05에 지난 달 데이터 집계하여 저장"""
    today = datetime.today()
    first_day_this_month = today.replace(day=1)
    last_month_date = first_day_this_month - timedelta(days=1)
    month_number_str = f"{last_month_date.year}-{last_month_date.month:02d}"

    user_ids = await processing_sleep_collection.distinct("id", {"month_number": month_number_str})
    sleep_serivce = SleepService()
    for id in user_ids:
        await sleep_serivce.store_monthly_average(id, month_number_str)
    print(f"Weekly average for {month_number_str} stored.")
    
async def update_sleep_data():
    """
    sleep_collection의 "daily" 문서에서 week_number 필드가 없는 경우,
    date 필드를 참조하여 week_number, month_number 를 생성한 후 업데이트
    """
    # aggregation_type이 'daily'이고 week_number 필드가 없는 문서를 찾음
    cursor = sleep_collection.find({
        "aggregation_type": "daily",
        "week_number": {"$exists": False}
    })
    docs = await cursor.to_list(length=None)
    for doc in docs:
        date_str = doc.get("date")
        data_obj = datetime.strptime(date_str, "%Y-%m-%d")
        month_number = f"{data_obj.year}-{data_obj.month:02d}" # 2025-03 형식
        
        if date_str:
            week_number = get_monthly_week(date_str)
            await sleep_collection.update_one(
                {"_id": doc["_id"]},
                {"$set": {"week_number": week_number, "month_number":month_number}}
            )