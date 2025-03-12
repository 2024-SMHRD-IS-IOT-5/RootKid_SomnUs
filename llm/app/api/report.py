from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.core.config import FASTAPI_SERVER_URL, TEST_SERVER_URL
from app.services.report.daily_report_service import daily_report_process
from app.services.report.weekly_report_service import weekly_report_process
from app.services.report.monthly_report_service import monthly_report_process
from typing import Any


router = APIRouter()

class ReportResponse(BaseModel):
    response: str
    



### 리포트 단위기간에 따른 매서드 생성 공간.
### if문으로 쉽게 구현 가능. 
### if report_type = ? 로 매서드 실행
### response.content를 chatbot/receive-report로 전송
### 후에 db/report_repository 실행

class SleepDataModel(BaseModel):
    sleep_data: dict[str, Any]
    
    
@router.post("")
async def make_report(sleep_data:dict):
    """ 메인 서버에서 받은 수면 데이터를 받아서 리포트 생성"""
    print(sleep_data)
    print("리포트 작성 시작!")
    type = sleep_data["aggregation_type"]
   
    if type ==  "daily":
        result = await daily_report_process(sleep_data)
        print(result)
        return {"message" : "일간 리포트 작성 완료", "result": result}
        
    elif type == "weekly":
        
        return {"message": "주간 리포트 작성 완료", "result": {"summary":"나는 전설이다","significant":"얜 정상은 아님","feedback":"정신과 상담 필요"}}
        
    elif type == "monthly":
        
        return {"message": "월간 리포트 작성 완료", "result": "한달요약"}
        

    
    
    
@router.get("/test/daily")
def make_report_test():
    print("test start!")
    result = daily_report_process()
    print(result)
    return "리포트 멘트 생성 테스트중"
    
# @router.post("/daily")
# async def daily_report_process(data : SleepDataModel):
#     """ 메인 서버에서 받은 dict형태의 수면 데이터를 처리"""
#     print("정상적으로 접속!")
#     try:
#         result = await daily_report_process(data.sleep_data)
#         return result
#     except Exception as e:
#         print("ERROR:", e)
#         raise HTTPException(status_code=500, detail="Internal Server Error")

# @router.post("/weekly", response_model=ReportResponse)
# async def weekly_report():
#     print("주간 요청 옴")
#     result = await send_report("주간")
#     return ReportResponse(response=result)

# @router.post("/monthly", response_model=ReportResponse)
# async def monthly_report():
#     result = await send_report("월간")
#     return ReportResponse(response=result)








#### 연결확인용 코드 #####
async def process_sleep_data(sleep_data: dict):
    """수면 데이터 처리 및 챗봇 응답 생성"""
    print(f"📊 수면 데이터 수신: {sleep_data}")  # ✅ 수면 데이터 로그 확인

    # 여기서 수면 데이터를 기반으로 분석/응답 생성 (예제)
    sleep_score = sleep_data.get("sleep_score", 0)
    if sleep_score > 85:
        recommendation = "수면 점수가 높습니다! 아주 좋은 상태입니다. 😊"
    elif sleep_score > 70:
        recommendation = "수면 점수가 괜찮습니다. 하지만 더 건강한 수면 습관을 가져보세요. 😉"
    else:
        recommendation = "수면 점수가 낮습니다. 수면 환경을 개선하는 것이 좋아요. 😴"
        
    print(recommendation)

    return {"chatbot_response": recommendation}


@router.post("/test")
async def receive_sleep_data(sleep_data: dict):
    """FastAPI 서버에서 받은 수면 데이터를 처리"""
    try:
        result = await process_sleep_data(sleep_data)
        return {"message": "수면 데이터 처리 완료", "result": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
