from db.database import db  # db import하기

async def get_sleep_data(user_id: str, start_date: str = None, end_date: str = None):
    """
    사용자 ID와 선택적 날짜 범위를 기준으로 수면 데이터를 조회합니다.

    Args:
        user_id (str): 조회할 사용자의 고유 ID
        start_date (str, optional): 조회 시작 날짜 (예: "2025-01-01")
        end_date (str, optional): 조회 종료 날짜 (예: "2025-01-31")

    Returns:
        list: 조건에 맞는 수면 데이터 리스트
    """
    query = {"user_id": user_id}
    
    # 날짜 조건 추가
    if start_date and end_date:
        # gte(greater than or equal)은 이상,
        # lte(less thatn or equal)은 이하라는 뜻이다.
        query["date"] = {"$gte": start_date, "$lte": end_date}
    elif start_date:
        query["date"] = {"$gte": start_date}
    elif end_date:
        query["date"] = {"$lte": end_date}
    
    # MongoDB의 sleep_collection에서 조건에 맞는 데이터를 비동기로 조회
    cursor = db.processing_sleep.find(query)
    sleep_data = await cursor.to_list(length=100)  # 결과 개수를 제한 (필요시 조정)
    
    return sleep_data
