from pydantic import BaseModel

class SleepDataResponse(BaseModel):
    """수면 데이터 응답 모델"""
    avg_sleep_time: str
    avg_deepsleep: str
    avg_lightsleep: str
    avg_remsleep: str
    avg_sleep_score: int