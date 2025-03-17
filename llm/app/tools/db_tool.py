from langchain.tools import BaseTool
from typing import Dict, Any, Optional, List, Union
from pymongo import MongoClient
import logging
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class SleepDataTool(BaseTool):
    """MongoDB에서 사용자의 수면 데이터를 검색하는 도구"""
    
    name = "sleep_data_retriever"
    description = """
    사용자의 수면 데이터를 검색할 때 사용합니다.
    일별, 주간, 월간 수면 데이터를 조회할 수 있습니다.
    사용자 ID와 날짜 범위를 필요로 합니다.
    데이터 유형을 지정할 수 있습니다(daily, weekly, monthly).
    
    입력 형식:
    {
        "user_id": "사용자 ID",
        "start_date": "YYYY-MM-DD 형식의 시작 날짜 (선택사항)",
        "end_date": "YYYY-MM-DD 형식의 종료 날짜 (선택사항)",
        "data_type": "daily, weekly, monthly 중 하나 (선택사항, 기본값: daily)"
    }
    """
    
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
        super().__init__()
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
                self.client = MongoClient(self.db_connection_string)
                self.db = self.client[self.db_name]
                self.daily = self.db[self.daily_collection]
                self.aggregated = self.db[self.aggregated_collection]
                if self.reports_collection:
                    self.reports = self.db[self.reports_collection]
            except Exception as e:
                logger.error(f"MongoDB 연결 초기화 실패: {str(e)}")
                raise
    
    def _run(
        self, 
        user_id: str, 
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        data_type: str = "daily"
    ) -> Dict[str, Any]:
        """
        사용자 ID와 날짜 범위를 기반으로 수면 데이터를 검색합니다.
        
        Args:
            user_id: 데이터를 검색할 사용자의 ID
            start_date: YYYY-MM-DD 형식의 시작 날짜 (선택사항)
            end_date: YYYY-MM-DD 형식의 종료 날짜 (선택사항)
            data_type: 검색할 데이터 유형 ("daily", "weekly", "monthly")
            
        Returns:
            검색된 수면 데이터를 포함하는 사전
        """
        try:
            # 필요시 DB 연결
            self._connect_db()
            
            # 기본 쿼리
            query = {"user_id": user_id}
            
            # 날짜 필터 추가 (제공된 경우)
            if start_date or end_date:
                date_filter = {}
                if start_date:
                    date_filter["$gte"] = start_date
                if end_date:
                    date_filter["$lte"] = end_date
                
                if date_filter:
                    query["date"] = date_filter
            
            # 데이터 유형에 따라 적절한 컬렉션 선택
            if data_type == "daily":
                collection = self.daily
            else:  # weekly or monthly
                collection = self.aggregated
                query["type"] = data_type
            
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
                    "user_id": user_id,
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
                    "user_id": user_id,
                    "date_range": {"start": start_date, "end": end_date} if (start_date or end_date) else "all",
                    "data_type": data_type
                }
            }
    
    async def _arun(
        self, 
        user_id: str, 
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        data_type: str = "daily"
    ) -> Dict[str, Any]:
        """비동기 버전의 실행 메서드"""
        # 동기 메서드를 호출 (필요한 경우 나중에 완전한 비동기 구현으로 교체)
        return self._run(user_id, start_date, end_date, data_type)
    
    def get_recent_data(self, user_id: str, days: int = 7, data_type: str = "daily") -> Dict[str, Any]:
        """
        사용자의 최근 수면 데이터를 가져오는 편의 메서드
        
        Args:
            user_id: 사용자 ID
            days: 최근 몇 일간의 데이터를 가져올지 지정
            data_type: 데이터 유형
            
        Returns:
            최근 수면 데이터
        """
        end_date = datetime.now().strftime("%Y-%m-%d")
        start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        
        return self._run(user_id, start_date, end_date, data_type)