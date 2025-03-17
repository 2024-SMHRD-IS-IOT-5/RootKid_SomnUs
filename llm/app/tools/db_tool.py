from langchain.tools import BaseTool
from typing import Dict, Any, Optional, List, Union
from pymongo import MongoClient
import logging
from datetime import datetime, timedelta
import calendar

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


class SleepDataTool(BaseTool):
    """MongoDB에서 사용자의 수면 데이터를 검색하는 도구"""
    
    name: str = "sleep_data_retriever"
    description: str = """
    사용자의 수면 데이터를 검색할 때 사용합니다.
    일별, 주간, 월간 수면 데이터를 조회할 수 있습니다.
    사용자 ID와 날짜 범위를 필요로 합니다.
    데이터 유형을 지정할 수 있습니다(daily, weekly, monthly).
    
    입력 형식:
    {
        "id": "사용자 ID",
        "start_date": "YYYY-MM-DD 형식의 시작 날짜 (선택사항)",
        "end_date": "YYYY-MM-DD 형식의 종료 날짜 (선택사항)",
        "data_type": "daily, weekly, monthly 중 하나 (선택사항, 기본값: daily)"
    }
    """
    
    # BaseTool에서는 받을 변수들에 대해서 필드 선언을 해두어야함.
    db_connection_string: str
    db_name: str
    daily_collection: str = "sleep"
    aggregated_collection: str = "processing_sleep"
    reports_collection: Optional[str] = None
    
    # 클라이언트 및 DB 관련 필드 선언
    client: Optional[Any] = None
    db: Optional[Any] = None
    daily: Optional[Any] = None
    aggregated: Optional[Any] = None
    reports: Optional[Any] = None
    
    def __init__(
        self,
        db_connection_string: str,
        db_name: str,
        daily_collection: str = "processing_sleep",
        aggregated_collection: str = "sleep",
        reports_collection: Optional[str] = None
    ):
        """
        Args:
            db_connection_string: MongoDB 연결 문자열
            db_name: 데이터베이스 이름
            daily_collection: 일별 수면 데이터가 저장된 컬렉션 이름
            aggregated_collection: 주별/월별 집계 데이터가 저장된 컬렉션 이름
            reports_collection: 보고서 데이터가 저장된 컬렉션 이름 (선택 사항)
        """
        super().__init__(
            db_connection_string=db_connection_string,
            db_name=db_name,
            daily_collection=daily_collection,
            aggregated_collection=aggregated_collection,
            reports_collection=reports_collection
        )
        
        self.db_connection_string = db_connection_string
        self.db_name = db_name
        self.daily_collection = daily_collection
        self.aggregated_collection = aggregated_collection
        self.reports_collection = reports_collection
        
        # 지연 초기화 패턴.
        # init 될 때 DB를 연결하지 않고, 필요한 시점까지 연결을 지연함.
        # 이렇게 함으로써 리소스 효율성이 증가하고, 시간이 감소한다.
        self.client = None
        self.db = None
        self.daily = None
        self.aggregated = None
        self.reports = None
        
    def _connect_db(self):
        """필요할 때 DB 연결을 초기화하는 헬퍼 메서드"""
        if self.client is None:
            try:
                logger.debug(f"Initializing MongoDB connection with: {self.db_connection_string}")
                self.client = MongoClient(self.db_connection_string)
                self.db = self.client[self.db_name]
                logger.debug(f"Using daily_collection: {self.daily_collection}, aggregated_collection: {self.aggregated_collection}, reports_collection: {self.reports_collection}")
                self.daily = self.db[self.daily_collection]
                self.aggregated = self.db[self.aggregated_collection]
                if self.reports_collection:
                    self.reports = self.db[self.reports_collection]
                logger.debug("MongoDB connection established successfully.")
            except Exception as e:
                logger.error(f"MongoDB 연결 초기화 실패: {str(e)}")
                raise
            
    def _convert_date_to_week(self, date_str: str) -> str:
        """YYYY-MM-DD 형식의 날짜를 YYYY-MM-W# 형식의 주 번호로 변환합니다."""
        
        # 날짜 파싱
        date_obj = datetime.strptime(date_str, "%Y-%m-%d") #str을 날짜 객체로 변환
        first_day_of_month = datetime(date_obj.year, date_obj.month, 1)
        
            # 월의 첫 번째 월요일 찾기
        first_monday = first_day_of_month
        while first_monday.weekday() != 0:  # 0 = 월요일
            first_monday += timedelta(days=1)
            
        # 첫 번째 월요일이 나오기 전까지는 이전 달의 마지막 주차 유지
        if date_obj < first_monday:
            previous_month = first_day_of_month - timedelta(days=1)
            last_week = (previous_month.day-1)//7 + 1
            return f"{previous_month.year}-{previous_month.month:02d}-W{last_week}"
        
        # 주차 계산 (첫 월요일부터 시작)
        delta_days = (date_obj - first_monday).days
        week_number = (delta_days // 7) + 1
        
        # YYYY-MM-W# 형식으로 반환
        return f"{date_obj.year}-{date_obj.month:02d}-W{week_number}"
    
    def _run(
        self, 
        id: str, 
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        data_type: str = "daily"
    ) -> Dict[str, Any]:
        """
        사용자 ID와 날짜 범위를 기반으로 수면 데이터를 검색합니다.
        
        Args:
            id: 데이터를 검색할 사용자의 ID
            start_date: YYYY-MM-DD 형식의 시작 날짜 (선택사항)
            end_date: YYYY-MM-DD 형식의 종료 날짜 (선택사항)
            data_type: 검색할 데이터 유형 ("daily", "weekly", "monthly")
            
        Returns:
            검색된 수면 데이터를 포함하는 사전
        """
        input_data_final = {}
        try:
            if isinstance(user_id, dict):
                input_data_final = user_id
                user_id = input_data_final.get("user_id", "").strip()
                start_date = input_data_final.get("start_date", start_date)
                end_date = input_data_final.get("end_date", end_date)
                data_type = input_data_final.get("data_type", data_type)
            else:
                user_id = user_id.strip()
                input_data_final = {
                    "id": user_id,
                    "start_date": start_date,
                    "end_date": end_date,
                    "data_type": data_type
                }
            
            
            # 필요시 DB 연결
            self._connect_db()
            
            # 기본 쿼리
            query = {"id": id}
            
            # 날짜 필터 추가 (제공된 경우)
            if start_date or end_date:
                # 데이터 유형에 따라 다른 필드 사용
                if data_type == "daily":
                    date_field = "date"
                elif data_type == "weekly":
                    date_field = "week_number"
                    # 날짜를 주 형식으로 변환 (예: "2025-02-10" -> "2025-02-W2")
                    if start_date:
                        start_date = self._convert_date_to_week(start_date)
                    if end_date:
                        end_date = self._convert_date_to_week(end_date)
                elif data_type == "monthly":
                    date_field = "month_number"
                    # 날짜를 월 형식으로 변환 (예: "2025-02-15" -> "2025-02")
                    if start_date:
                        start_date = start_date[:7]  # "YYYY-MM-DD" -> "YYYY-MM"
                    if end_date:
                        end_date = end_date[:7]  # "YYYY-MM-DD" -> "YYYY-MM"
                
                date_filter = {}
                if start_date:
                    date_filter["$gte"] = start_date
                if end_date:
                    date_filter["$lte"] = end_date
                
                if date_filter:
                    query[date_field] = date_filter
            
            # 데이터 유형에 따라 적절한 컬렉션 선택
            if data_type == "daily":
                collection = self.daily
            else:  # weekly or monthly
                collection = self.aggregated
                query["aggregation_type"] = data_type
            
            # 데이터 검색
            cursor = collection.find(query)
            results = list(cursor)
            
            # MongoDB ObjectId를 문자열로 변환 (직렬화를 위해)
            for result in results:
                if '_id' in result:
                    result['_id'] = str(result['_id'])
            
            return {
                "status": "success",
                "data": results,
                "count": len(results),
                "query_info": {
                    "id": id,
                    "date_range": {"start": start_date, "end": end_date} if (start_date or end_date) else "all",
                    "data_type": data_type
                }
            }
        
        except Exception as e:
            logger.error(f"수면 데이터 검색 오류: {str(e)}")
            return {
                "status": "error",
                "error": str(e),
                "query_info": {
                "id": id,
                "date_range": {"start": start_date, "end": end_date} if (start_date or end_date) else "all",
                "data_type": data_type
                }
            }
    
    def get_recent_data(self, id: str, days: int = 7, data_type: str = "daily") -> Dict[str, Any]:
        """
        사용자의 최근 수면 데이터를 가져오는 편의 메서드
        """
        end_date = datetime.now().strftime("%Y-%m-%d")
        start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        logger.debug(f"get_recent_data called for id: {id} with start_date: {start_date} and end_date: {end_date}, data_type: {data_type}")
        result = self._run(id, start_date, end_date, data_type)
        logger.debug(f"get_recent_data result: {result}")
        return result
