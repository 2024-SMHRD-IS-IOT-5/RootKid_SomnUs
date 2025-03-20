import json
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
from motor.motor_asyncio import AsyncIOMotorCollection
import asyncio

from app.db.database import db

class ReportTool:
    def __init__(self):
        self.reports_collection: AsyncIOMotorCollection = db["reports"]

    def search_reports(self, query: str, user_id: str = None) -> str:
        """
        사용자의 수면 리포트를 검색합니다.
        
        Args:
            query: 사용자 질문
            user_id: 사용자 ID (기본값: None)
            
        Returns:
            str: 검색된 리포트 내용
        """
        # 사용자 ID가 제공되지 않았다면 추출 시도
        if not user_id:
            # 쿼리에서 ID 추출 시도
            if "smhrd" in query.lower():
                user_id = "smhrd"
            else:
                return "사용자 ID를 확인할 수 없습니다. 다시 시도해주세요."
        
        # 리포트 유형 결정 (일간, 주간, 월간)
        report_type = self._determine_report_type(query)
        
        # 검색할 날짜 추출
        date_str = self._extract_date_from_query(query, report_type)
        
        # 비동기 메서드를 동기적으로 실행
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        try:
            # 리포트 검색
            if report_type == "all":
                # 모든 유형의 최근 리포트 검색
                return loop.run_until_complete(self._get_recent_reports(user_id))
            else:
                # 특정 유형과 날짜의 리포트 검색
                return loop.run_until_complete(self._get_specific_report(user_id, report_type, date_str))
        finally:
            loop.close()
    
    def _determine_report_type(self, query: str) -> str:
        """
        쿼리를 분석하여 필요한 리포트 유형을 결정합니다.
        
        Args:
            query: 사용자 질문
            
        Returns:
            str: 리포트 유형 (daily, weekly, monthly, all)
        """
        query = query.lower()
        
        # 일간 리포트 키워드
        daily_keywords = ["하루", "일간", "일일", "어제", "오늘", "daily"]
        for keyword in daily_keywords:
            if keyword in query:
                return "daily"
        
        # 주간 리포트 키워드
        weekly_keywords = ["주간", "일주일", "지난주", "이번 주", "weekly"]
        for keyword in weekly_keywords:
            if keyword in query:
                return "weekly"
        
        # 월간 리포트 키워드
        monthly_keywords = ["월간", "한달", "지난달", "이번 달", "monthly"]
        for keyword in monthly_keywords:
            if keyword in query:
                return "monthly"
        
        # 기본값은 모든 유형
        return "all"
    
    def _extract_date_from_query(self, query: str, report_type: str) -> Optional[str]:
        """
        쿼리에서 날짜 정보를 추출합니다.
        
        Args:
            query: 사용자 질문
            report_type: 리포트 유형
            
        Returns:
            Optional[str]: 추출된 날짜 또는 None
        """
        query = query.lower()
        today = datetime.now()
        
        if report_type == "daily":
            # 일간 리포트 날짜 (YYYY-MM-DD)
            if "어제" in query:
                yesterday = today - timedelta(days=1)
                return yesterday.strftime("%Y-%m-%d")
            elif "오늘" in query:
                return today.strftime("%Y-%m-%d")
            
            # 추가 날짜 패턴 처리 가능
        
        elif report_type == "weekly":
            # 주간 리포트 날짜 (YYYY-MM-Wn)
            if "지난주" in query:
                last_week = today - timedelta(days=7)
                return f"{last_week.year}-{last_week.month:02d}-W{int(last_week.strftime('%W'))}"
            elif "이번 주" in query:
                return f"{today.year}-{today.month:02d}-W{int(today.strftime('%W'))}"
        
        elif report_type == "monthly":
            # 월간 리포트 날짜 (YYYY-MM)
            if "지난달" in query:
                last_month = today.replace(day=1) - timedelta(days=1)
                return f"{last_month.year}-{last_month.month:02d}"
            elif "이번 달" in query:
                return f"{today.year}-{today.month:02d}"
            
            # 월 이름으로 검색
            months = {"1월": "01", "2월": "02", "3월": "03", "4월": "04", "5월": "05", "6월": "06",
                     "7월": "07", "8월": "08", "9월": "09", "10월": "10", "11월": "11", "12월": "12"}
            
            for month_name, month_num in months.items():
                if month_name in query:
                    return f"{today.year}-{month_num}"
        
        # 날짜를 추출할 수 없는 경우
        return None
    
    async def _get_recent_reports(self, user_id: str) -> str:
        """
        사용자의 최근 리포트를 검색합니다.
        
        Args:
            user_id: 사용자 ID
            
        Returns:
            str: 최근 리포트 내용
        """
        # 최근 5개 리포트 검색
        cursor = self.reports_collection.find(
            {"id": user_id},
            sort=[("timestamp", -1)],
            limit=5
        )
        
        reports = await cursor.to_list(length=5)
        
        if not reports:
            return f"최근 리포트를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 결과 형식화
        result = "최근 수면 리포트:\n\n"
        
        for i, report in enumerate(reports):
            report_type = report.get("type", "알 수 없음")
            date = report.get("date", "날짜 없음")
            
            result += f"{i+1}. {date} ({report_type} 리포트)\n"
            
            try:
                # comment 필드가 문자열화된 JSON 배열인 경우
                comment = json.loads(report.get("comment", "[]"))
                for item in comment:
                    result += f"   - {item}\n"
            except json.JSONDecodeError:
                # comment 필드가 일반 문자열인 경우
                result += f"   - {report.get('comment', '')}\n"
            
            result += "\n"
        
        return result
    
    async def _get_specific_report(self, user_id: str, report_type: str, date_str: Optional[str]) -> str:
        """
        특정 유형과 날짜의 리포트를 검색합니다.
        
        Args:
            user_id: 사용자 ID
            report_type: 리포트 유형
            date_str: 날짜 문자열 (형식은 리포트 유형에 따라 다름)
            
        Returns:
            str: 리포트 내용
        """
        # 검색 조건
        query = {"id": user_id, "type": report_type}
        
        if date_str:
            query["date"] = date_str
        
        # 리포트 검색
        if date_str:
            # 특정 날짜의 리포트
            report = await self.reports_collection.find_one(query)
            
            if not report:
                return f"{date_str} 날짜의 {report_type} 리포트를 찾을 수 없습니다. (사용자 ID: {user_id})"
            
            # 결과 형식화
            result = f"{date_str} {report_type} 리포트:\n\n"
            
            try:
                # comment 필드가 문자열화된 JSON 배열인 경우
                comment = json.loads(report.get("comment", "[]"))
                for item in comment:
                    result += f"- {item}\n"
            except json.JSONDecodeError:
                # comment 필드가 일반 문자열인 경우
                result += f"{report.get('comment', '')}\n"
            
            return result
        else:
            # 최근 해당 유형의 리포트
            report = await self.reports_collection.find_one(
                {"id": user_id, "type": report_type},
                sort=[("timestamp", -1)]
            )
            
            if not report:
                return f"최근 {report_type} 리포트를 찾을 수 없습니다. (사용자 ID: {user_id})"
            
            # 결과 형식화
            date = report.get("date", "날짜 없음")
            result = f"{date} {report_type} 리포트 (최근):\n\n"
            
            try:
                # comment 필드가 문자열화된 JSON 배열인 경우
                comment = json.loads(report.get("comment", "[]"))
                for item in comment:
                    result += f"- {item}\n"
            except json.JSONDecodeError:
                # comment 필드가 일반 문자열인 경우
                result += f"{report.get('comment', '')}\n"
            
            return result