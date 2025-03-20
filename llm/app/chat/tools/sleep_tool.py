from motor.motor_asyncio import AsyncIOMotorCollection
import json
from datetime import datetime
import pytz

from app.db.database import db

class SleepTool:
        
    # async def db(self):
    #     id = "smhrd"
        
    #     data = await self.sleep_collection.find({"id":"smhrd", "date": {"$gte":"2025-03-01","$lte":"2025-03-21"}}).to_list(length=None)
    #     formatted_data = json.dumps(data, ensure_ascii=False, indent=2)
    #     return formatted_data
        
    def get_sleep_data(self, query: str, user_id: str = None) -> str:
        
        korea_timezone = pytz.timezone('Asia/Seoul')
        korea_time = datetime.now(korea_timezone)
        self.time = korea_time.strftime("%Y-%m-%d %H:%M:%S")
        
        template = """
        <key 설명>
        "date" : 날짜,
        "sleep_score" : 수면 점수,
        "wakeup_count" : 깨어난 횟수,
        "lightsleep_duration" : 얕은 수면 지속 시간
        "deepsleep_duration" : 깊은 수면 지속 시간
        "remsleep_duration" : 렘 수면 지속 시간
        "hr_average": 심박수 평균, 
        "hr_min": 최소 심박수,
        "hr_max": 최대 심박수,
        "rr_average": 평균 호흡 횟수,
        "rr_min": 최소 호흡 횟수,
        "rr_max": 최대 호흡 횟수,
        "breathing_disturbances_intensity" : 호흡 곤란 횟수
        <오늘 데이터>
  "id": "smhrd",
  "date": "2025-03-19",
  "startDt": 1742310000,
  "endDt": 1742336520,
  "lightsleep_duration": 15420,
  "deepsleep_duration": 3540,
  "wakeup_count": 1,
  "remsleep_duration": 6480,
  "hr_average": 57,
  "hr_min": 48,
  "hr_max": 70,
  "rr_average": 15,
  "rr_min": 11,
  "rr_max": 25,
  "breathing_disturbances_intensity": 33,
  "snoring": 10320,
  "snoring_episode_count": 15,
  "sleep_score": 78,
  "aggregation_type": "daily"

  <어제 데이터>
  "id": "smhrd",
  "date": "2025-03-18",
  "startDt": 1742234160,
  "endDt": 1742262900,
  "lightsleep_duration": 16740,
  "deepsleep_duration": 2160,
  "wakeup_count": 2,
  "remsleep_duration": 7140,
  "hr_average": 59,
  "hr_min": 51,
  "hr_max": 71,
  "rr_average": 15,
  "rr_min": 11,
  "rr_max": 22,
  "breathing_disturbances_intensity": 39,
  "snoring": 12240,
  "snoring_episode_count": 25,
  "sleep_score": 75,
  "aggregation_type": "daily",
  " month_number": "2025-03",
  "week_number": "2025-03-W3"

  <이틀 전 데이터>
  "id": "smhrd",
  "date": "2025-03-17",
  "startDt": 1742149080,
  "endDt": 1742174820,
  "lightsleep_duration": 15120,
  "deepsleep_duration": 1380,
  "wakeup_count": 1,
  "remsleep_duration": 7020,
  "hr_average": 63,
  "hr_min": 53,
  "hr_max": 77,
  "rr_average": 15,
  "rr_min": 10,
  "rr_max": 25,
  "breathing_disturbances_intensity": 34,
  "snoring": 8220,
  "snoring_episode_count": 20,
  "sleep_score": 61,
  "aggregation_type": "daily",
  " month_number": "2025-03",
  "week_number": "2025-03-W2"
]

        """
        return template