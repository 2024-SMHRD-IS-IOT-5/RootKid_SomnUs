from fastapi import APIRouter, HTTPException, Query
from core.database import client, users_collection, sleep_collection, report_collection
from bson import ObjectId # ObjectID 변환을 위해 추가
from core.security import hash_password, verify_password, create_access_token
from datetime import datetime
from services.sleep_service import get_monthly_week, SleepService, update_sleep_data
from utils.time import get_month
from dateutil.relativedelta import relativedelta
from services.prediction_service import compute_sleep_score_mlp



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

@router.get("/test-update")
async def update_sleep_duration():
    """
    모든 sleep 컬렉션 문서에 대해 "sleep_duration" 필드를
    "endDt" - "startDt" 값으로 업데이트합니다.
    """
    try:
        result = await sleep_collection.update_many(
            {},
            [{"$set": {"sleep_duration": {"$subtract": ["$endDt", "$startDt"]}}}]
        )
        return {"message": "업데이트 완료", "modified_count": result.modified_count}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"업데이트 실패: {e}")

@router.get("/test-find")
async def test_find():
    #MongoDB에서 데이터 조회"""
    try:
        data = await report_collection.find_one({"id": "smhrd", "date":"2025-02-W1", "type":"weekly"}, sort=[("_id", -1)],
            projection={"comment": 1, "_id": 0})
      
        chatbot_response = data.get("comment") if data else None 
    
        if data:
            # '_id_를 문자열로 변환하여 반환
            #data["_id"] = str(data["_id"])
            return {"message": "데이터 조회 성공!", 
                    "chatbot_response[0]": chatbot_response[0],
                    "chatbot_response[1]": chatbot_response[1],
                    "chatbot_response[2]": chatbot_response[2],
                    "chatbot_response": chatbot_response}
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
    week_number = get_monthly_week("2025-03-16", numeric=True)
  
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
    
@router.get("/test/weekly")
async def get_weekly_sleep_data():
    """주간 수면 데이터 """
    try:
        data = await SleepService.get_weekly_sleep_data(user_id="smhrd")
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))    
    

@router.get("/sleep-data/mlp-update")
async def mlp_update_endpoint(
    date: str = Query(..., description="2025-03-20")
):
    """
    DB에 저장된 특정 날짜의 수면 데이터를 조회하여, 
    MLP 모델로 sleep_score를 예측하고 해당 문서의 sleep_score 필드를 업데이트한 후 결과 반환.
    """
    # 날짜를 기준으로 데이터를 조회합니다.
    query = {"date": date}
    sleep_data = await sleep_collection.find_one(query)
    if not sleep_data:
        raise HTTPException(status_code=404, detail="해당 날짜의 수면 데이터가 존재하지 않습니다")
    
    # sleep_data의 "id" 필드를 이용하고, 해당 문서의 _id를 sleep_record_id로 사용합니다.
    result = await compute_sleep_score_mlp(sleep_data["id"], sleep_record_id=str(sleep_data["_id"]))
    new_score = int(result.get("sleep_score"))
    
    update_result = await sleep_collection.update_one(
        {"_id": sleep_data["_id"]},
        {"$set": {"sleep_score": new_score}}
    )
    
    if update_result.modified_count == 0:
        raise HTTPException(status_code=500, detail="수면 점수 업데이트 실패")
    
    return {"message": "수면 점수 업데이트 완료", "sleep_score": new_score}
