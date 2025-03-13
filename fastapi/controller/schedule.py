from fastapi import APIRouter, FastAPI
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from services.sleep_service import weekly_average_job, monthly_average_job  

scheduler = AsyncIOScheduler()
router = APIRouter()

def init_scheduler(app: FastAPI) -> None:
    # 스케줄러 작업 등록
    scheduler.add_job(weekly_average_job, "cron", day_of_week="sun", hour=23, minute=59)
    scheduler.add_job(monthly_average_job, "cron", day=1, hour=0, minute=5)
    scheduler.start()

@router.get("/scheduler-status")
async def scheduler_status():
    return {"message": "Scheduler is running."}