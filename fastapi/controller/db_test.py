from fastapi import APIRouter, HTTPException
from core.database import client, users_collection
from bson import ObjectId # ObjectID 변환을 위해 추가
from core.security import hash_password, verify_password, create_access_token
from datetime import datetime
from services.sleep_service import get_monthly_week, SleepService, update_sleep_data
from utils.time import get_month
from dateutil.relativedelta import relativedelta

router = APIRouter()

@router.get("/test-db")
async def test_db_connection():
    #MongoDB 연결 테스트"""
    try:
        # ✅ MongoDB의 모든 데이터베이스 목록 가져오기
        db_list = await client.list_database_names()
        return {"message": "MongoDB 연결 성공!", "databases": db_list}
    except Exception as e:
        return {"error": str(e)}

@router.post("/test-insert")
async def test_insert():
    #MongoDB에 테스트 데이터 삽입"""
    try:
        existing_user = await users_collection.find_one({"id": "test22"})
        if existing_user:
            return {"error": "이미 존재하는 아이디입니다."}
        
        password = "1234"
        hashed_password = hash_password(password)
        new_user = {"id":"test123", "password": hashed_password, "username":"smhrd", "userage": 20100101, "userweight":40}
        result = await users_collection.insert_one(new_user)
        return {"message": "데이터 삽입 성공!", "inserted_id": str(result.inserted_id)}
    
    except Exception as e:
        return {"error": str(e)}

@router.get("/test-find")
async def test_find():
    #MongoDB에서 데이터 조회"""
    try:
        data = await users_collection.find_one({"id": "smhrd"})
         
        if data:
            # '_id_를 문자열로 변환하여 반환
            data["_id"] = str(data["_id"])
            return {"message": "데이터 조회 성공!", "data": data}
        else:
            return {"message": "데이터 없음"}
        
    except Exception as e:
        return {"error": str(e)}
    

@router.get("/aggregate/weekly")
async def aggregate_weekly(user_id: str = "smhrd", date: str = None):
    """
    주어진 날짜(또는 오늘)를 기준으로 주간 집계 작업을 실행하고 결과를 반환합니다.
    예) /aggregate/weekly?user_id=test_user&date=2025-03-03
    """
    # 날짜가 지정되지 않았다면 오늘 날짜 사용
    if date is None:
        date = datetime.today().strftime("%Y-%m-%d")
    # 주차 계산 (numeric=True 옵션으로 숫자 반환)
    week_number = get_monthly_week("2025-02-16", numeric=True)
  
    service = SleepService()
    result = await service.store_weekly_average(user_id, week_number)
    return {"user_id":user_id,"week_number": week_number,"result": result}    


@router.get("/aggregate/monthly")
async def aggregate_weekly(user_id: str = "smhrd", date: str = None):
    """
    주어진 날짜(또는 오늘)를 기준으로 월간 집계 작업을 실행하고 결과를 반환합니다.
    """
    # 날짜가 지정되지 않았다면 오늘 날짜 사용
    if date is None:
        date = "2025-03-01"
        
    # 현재 날짜를 datetime 객체로 변환한 후, 지난 달 날짜 계산
    current_date = datetime.strptime(date, "%Y-%m-%d")
    previous_month_date = current_date - relativedelta(months=1)
    # 지난 달의 월 정보를 numeric 형식으로 반환 (예: "2025-02")
    month_number = get_month(previous_month_date.strftime("%Y-%m-%d"), numeric=True)
  
    service = SleepService()
    result = await service.store_monthly_average(user_id, month_number)
    return {"user_id": user_id, "month_number": month_number, "result": result}

@router.get("/update-week-number")
async def update_week_number():
    try:
        await update_sleep_data()
        return {"message": "모든 daily 문서에 week_number 업데이트 완료"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))