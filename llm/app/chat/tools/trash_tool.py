from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import json
from motor.motor_asyncio import AsyncIOMotorCollection
import asyncio

from app.db.database import db

class SleepTool:
    def __init__(self):
        self.sleep_collection: AsyncIOMotorCollection = db["sleep"]
        self.processing_sleep_collection: AsyncIOMotorCollection = db["processing_sleep"]
    
    # sleep_tool.py의 get_sleep_data 메서드를 동기 버전으로 변경

    def get_sleep_data(self, query: str, user_id: str = None) -> str:
        """
        사용자의 수면 데이터를 분석하여 반환합니다.
        
        Args:
            query: 사용자 질문
            user_id: 사용자 ID (기본값: None)
            
        Returns:
            str: 수면 데이터 분석 결과
        """
        # 사용자 ID가 제공되지 않았다면 추출 시도
        if not user_id:
            # 쿼리에서 ID 추출 시도
            if "smhrd" in query.lower():
                user_id = "smhrd"
            else:
                return "사용자 ID를 확인할 수 없습니다. 다시 시도해주세요."
        
        # 쿼리 분석하여 필요한 데이터 범위 결정
        data_range = self._determine_data_range(query)
        
        # 비동기 메서드를 동기적으로 실행
        # 주의: 다음 방식은 FastAPI 내에서 실행되지 않는 별도의 스크립트에서만 사용해야 함
        # FastAPI 애플리케이션에서는 이벤트 루프 관련 오류 발생 가능
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        try:
            if "recent" in data_range:
                # 최근 수면 데이터 조회
                return loop.run_until_complete(self._get_recent_sleep_data(user_id))
            elif "daily" in data_range:
                # 특정 날짜 데이터 조회
                date_str = self._extract_date(query)
                if not date_str:
                    # 날짜를 찾을 수 없으면 최근 데이터 반환
                    return loop.run_until_complete(self._get_recent_sleep_data(user_id))
                return loop.run_until_complete(self._get_daily_sleep_data(user_id, date_str))
            elif "weekly" in data_range:
                # 주간 데이터 조회
                week_str = self._extract_week(query)
                if not week_str:
                    # 최근 주간 데이터 반환
                    return loop.run_until_complete(self._get_recent_weekly_data(user_id))
                return loop.run_until_complete(self._get_weekly_sleep_data(user_id, week_str))
            elif "monthly" in data_range:
                # 월간 데이터 조회
                month_str = self._extract_month(query)
                if not month_str:
                    # 최근 월간 데이터 반환
                    return loop.run_until_complete(self._get_recent_monthly_data(user_id))
                return loop.run_until_complete(self._get_monthly_sleep_data(user_id, month_str))
            else:
                # 기본적으로 최근 데이터 반환
                return loop.run_until_complete(self._get_recent_sleep_data(user_id))
        finally:
            loop.close()
        
    def _determine_data_range(self, query: str) -> str:
        """
        쿼리를 분석하여 필요한 데이터 범위를 결정합니다.
        
        Args:
            query: 사용자 질문
            
        Returns:
            str: 데이터 범위 유형 (recent, daily, weekly, monthly)
        """
        query = query.lower()
        
        # 날짜 패턴 찾기
        date_keywords = ["어제", "하루", "일일", "오늘", "2025년", "2024년", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
        for keyword in date_keywords:
            if keyword in query:
                return "daily"
        
        # 주간 패턴 찾기
        week_keywords = ["지난주", "일주일", "주간", "이번 주"]
        for keyword in week_keywords:
            if keyword in query:
                return "weekly"
        
        # 월간 패턴 찾기
        month_keywords = ["지난달", "한 달", "월간", "이번 달", "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
        for keyword in month_keywords:
            if keyword in query:
                return "monthly"
        
        # 기본값은 최근 데이터
        return "recent"
    
    def _extract_date(self, query: str) -> Optional[str]:
        """
        쿼리에서 날짜 정보를 추출합니다.
        
        Args:
            query: 사용자 질문
            
        Returns:
            Optional[str]: 추출된 날짜 (YYYY-MM-DD 형식) 또는 None
        """
        # 여기서는 간단한 패턴만 처리합니다
        # 실제 서비스에서는 더 복잡한 날짜 추출 로직이 필요할 수 있습니다
        
        today = datetime.now()
        
        if "어제" in query:
            yesterday = today - timedelta(days=1)
            return yesterday.strftime("%Y-%m-%d")
        elif "오늘" in query:
            return today.strftime("%Y-%m-%d")
        
        # 추가 날짜 패턴 처리 가능
        # 여기서는 간단한 구현만 제공
        
        return None
    
    def _extract_week(self, query: str) -> Optional[str]:
        """
        쿼리에서 주차 정보를 추출합니다.
        
        Args:
            query: 사용자 질문
            
        Returns:
            Optional[str]: 추출된 주차 (YYYY-MM-Wn 형식) 또는 None
        """
        # 여기서는 간단한 패턴만 처리합니다
        
        today = datetime.now()
        
        if "지난주" in query:
            last_week = today - timedelta(days=7)
            return f"{last_week.strftime('%Y-%m')}-W{last_week.strftime('%W')}"
        elif "이번 주" in query:
            return f"{today.strftime('%Y-%m')}-W{today.strftime('%W')}"
        
        # 추가 주차 패턴 처리 가능
        
        return None
    
    def _extract_month(self, query: str) -> Optional[str]:
        """
        쿼리에서 월 정보를 추출합니다.
        
        Args:
            query: 사용자 질문
            
        Returns:
            Optional[str]: 추출된 월 (YYYY-MM 형식) 또는 None
        """
        # 여기서는 간단한 패턴만 처리합니다
        
        today = datetime.now()
        
        if "지난달" in query or "지난 달" in query:
            last_month = today.replace(day=1) - timedelta(days=1)
            return last_month.strftime("%Y-%m")
        elif "이번 달" in query:
            return today.strftime("%Y-%m")
        
        # 월 이름으로 검색
        months = {"1월": "01", "2월": "02", "3월": "03", "4월": "04", "5월": "05", "6월": "06",
                 "7월": "07", "8월": "08", "9월": "09", "10월": "10", "11월": "11", "12월": "12"}
        
        for month_name, month_num in months.items():
            if month_name in query:
                # 연도는 현재 연도로 가정
                return f"{today.year}-{month_num}"
        
        return None
    
    async def _get_recent_sleep_data(self, user_id: str) -> str:
        """
        사용자의 최근 수면 데이터를 조회합니다.
        
        Args:
            user_id: 사용자 ID
            
        Returns:
            str: 최근 수면 데이터 문자열
        """
        # 최근 7일간의 데이터 조회
        today = datetime.now()
        start_date = (today - timedelta(days=7)).strftime("%Y-%m-%d")
        
        cursor = self.sleep_collection.find(
            {"id": user_id, "date": {"$gte": start_date}},
            sort=[("date", -1)],
            limit=7
        )
        
        sleep_data = await cursor.to_list(length=7)
        
        if not sleep_data:
            return f"최근 7일간의 수면 데이터를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 최근 데이터 형식화
        result = "최근 수면 데이터 분석:\n\n"
        
        # 평균 계산
        avg_sleep_score = sum(data.get("sleep_score", 0) for data in sleep_data) / len(sleep_data)
        avg_deep_sleep = sum(data.get("deepsleep_duration", 0) for data in sleep_data) / len(sleep_data)
        avg_light_sleep = sum(data.get("lightsleep_duration", 0) for data in sleep_data) / len(sleep_data)
        avg_rem_sleep = sum(data.get("remsleep_duration", 0) for data in sleep_data) / len(sleep_data)
        
        # 데이터 요약
        result += f"평균 수면 점수: {avg_sleep_score:.1f}/100\n"
        result += f"평균 깊은 수면: {self._format_duration(avg_deep_sleep)}\n"
        result += f"평균 얕은 수면: {self._format_duration(avg_light_sleep)}\n"
        result += f"평균 REM 수면: {self._format_duration(avg_rem_sleep)}\n\n"
        
        # 각 일자별 데이터
        result += "일자별 데이터:\n"
        for data in sleep_data:
            date = data.get("date", "날짜 없음")
            score = data.get("sleep_score", 0)
            start_time = datetime.fromtimestamp(data.get("startDt", 0)).strftime("%H:%M")
            end_time = datetime.fromtimestamp(data.get("endDt", 0)).strftime("%H:%M")
            duration = (data.get("deepsleep_duration", 0) + data.get("lightsleep_duration", 0) + 
                        data.get("remsleep_duration", 0))
            
            result += f"- {date}: 점수 {score}/100, {start_time}~{end_time}, 총 수면 {self._format_duration(duration)}\n"
        
        return result
    
    async def _get_weekly_sleep_data(self, user_id: str, week_str: str) -> str:
        """
        특정 주차의 수면 데이터를 조회합니다.
        
        Args:
            user_id: 사용자 ID
            week_str: 주차 문자열 (YYYY-MM-Wn)
            
        Returns:
            str: 주간 수면 데이터 문자열
        """
        weekly_data = await self.processing_sleep_collection.find_one(
            {"id": user_id, "aggregation_type": "weekly", "week_number": week_str}
        )
        
        if not weekly_data:
            return f"{week_str} 주차의 수면 데이터를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 해당 주차에 속한 일별 데이터도 조회
        cursor = self.sleep_collection.find(
            {"id": user_id, "week_number": week_str}
        )
        daily_data = await cursor.to_list(length=7)
        
        # 결과 형식화
        result = f"{week_str} 주간 수면 데이터 분석:\n\n"
        result += f"평균 수면 점수: {weekly_data.get('avg_sleep_score', 0)}/100\n"
        result += f"평균 수면 시간: {self._format_duration(weekly_data.get('avg_sleep_time', 0))}\n\n"
        
        # 수면 단계별 시간
        result += "평균 수면 단계:\n"
        result += f"- 깊은 수면: {self._format_duration(weekly_data.get('avg_deep_sleep', 0))}\n"
        result += f"- 얕은 수면: {self._format_duration(weekly_data.get('avg_light_sleep', 0))}\n"
        result += f"- REM 수면: {self._format_duration(weekly_data.get('avg_rem_sleep', 0))}\n\n"
        
        # 일별 데이터 요약
        if daily_data:
            result += "일자별 수면 점수:\n"
            for day in sorted(daily_data, key=lambda x: x.get("date", "")):
                date = day.get("date", "날짜 없음")
                score = day.get("sleep_score", 0)
                total_sleep = (
                    day.get("deepsleep_duration", 0) + 
                    day.get("lightsleep_duration", 0) + 
                    day.get("remsleep_duration", 0)
                )
                result += f"- {date}: 점수 {score}/100, 총 수면 {self._format_duration(total_sleep)}\n"
        
        return result
    
    async def _get_recent_monthly_data(self, user_id: str) -> str:
        """
        사용자의 최근 월간 집계 데이터를 조회합니다.
        
        Args:
            user_id: 사용자 ID
            
        Returns:
            str: 최근 월간 데이터 문자열
        """
        # 최근 월간 데이터 조회
        monthly_data = await self.processing_sleep_collection.find_one(
            {"id": user_id, "aggregation_type": "monthly"},
            sort=[("month_number", -1)]
        )
        
        if not monthly_data:
            return f"최근 월간 수면 데이터를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 결과 형식화
        month_str = monthly_data.get('month_number', '알 수 없는 월')
        result = f"{month_str} 월간 수면 데이터 분석:\n\n"
        result += f"평균 수면 점수: {monthly_data.get('avg_sleep_score', 0)}/100\n"
        result += f"평균 수면 시간: {self._format_duration(monthly_data.get('avg_sleep_time', 0))}\n\n"
        
        # 수면 단계별 시간
        result += "평균 수면 단계:\n"
        result += f"- 깊은 수면: {self._format_duration(monthly_data.get('avg_deep_sleep', 0))}\n"
        result += f"- 얕은 수면: {self._format_duration(monthly_data.get('avg_light_sleep', 0))}\n"
        result += f"- REM 수면: {self._format_duration(monthly_data.get('avg_rem_sleep', 0))}\n"
        
        return result
    
    async def _get_monthly_sleep_data(self, user_id: str, month_str: str) -> str:
        """
        특정 월의 수면 데이터를 조회합니다.
        
        Args:
            user_id: 사용자 ID
            month_str: 월 문자열 (YYYY-MM)
            
        Returns:
            str: 월간 수면 데이터 문자열
        """
        monthly_data = await self.processing_sleep_collection.find_one(
            {"id": user_id, "aggregation_type": "monthly", "month_number": month_str}
        )
        
        if not monthly_data:
            return f"{month_str} 월의 수면 데이터를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 해당 월에 속한 주간 데이터 조회
        cursor = self.processing_sleep_collection.find(
            {"id": user_id, "aggregation_type": "weekly", "month_number": month_str}
        )
        weekly_data = await cursor.to_list(length=5)  # 한 달에 최대 5주
        
        # 결과 형식화
        result = f"{month_str} 월간 수면 데이터 분석:\n\n"
        result += f"평균 수면 점수: {monthly_data.get('avg_sleep_score', 0)}/100\n"
        result += f"평균 수면 시간: {self._format_duration(monthly_data.get('avg_sleep_time', 0))}\n\n"
        
        # 수면 단계별 시간
        result += "평균 수면 단계:\n"
        result += f"- 깊은 수면: {self._format_duration(monthly_data.get('avg_deep_sleep', 0))}\n"
        result += f"- 얕은 수면: {self._format_duration(monthly_data.get('avg_light_sleep', 0))}\n"
        result += f"- REM 수면: {self._format_duration(monthly_data.get('avg_rem_sleep', 0))}\n\n"
        
        # 주간 데이터 요약
        if weekly_data:
            result += "주간 수면 점수:\n"
            for week in sorted(weekly_data, key=lambda x: x.get("week_number", "")):
                week_number = week.get("week_number", "주차 없음")
                score = week.get("avg_sleep_score", 0)
                sleep_time = week.get("avg_sleep_time", 0)
                result += f"- {week_number}: 평균 점수 {score}/100, 평균 수면 {self._format_duration(sleep_time)}\n"
        
        return result
    
    def _format_duration(self, seconds: int) -> str:
        """
        초 단위 시간을 시간과 분 형식으로 변환합니다.
        
        Args:
            seconds: 초 단위 시간
            
        Returns:
            str: HH시간 MM분 형식의 시간
        """
        hours, remainder = divmod(seconds, 3600)
        minutes, _ = divmod(remainder, 60)
        
        if hours > 0:
            return f"{hours}시간 {minutes}분"
        else:
            return f"{minutes}분"
    
    async def _get_daily_sleep_data(self, user_id: str, date_str: str) -> str:
        """
        특정 날짜의 수면 데이터를 조회합니다.
        
        Args:
            user_id: 사용자 ID
            date_str: 날짜 문자열 (YYYY-MM-DD)
            
        Returns:
            str: 일간 수면 데이터 문자열
        """
        sleep_data = await self.sleep_collection.find_one({"id": user_id, "date": date_str})
        
        if not sleep_data:
            return f"{date_str} 날짜의 수면 데이터를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 수면 시작/종료 시간 변환
        start_time = datetime.fromtimestamp(sleep_data.get("startDt", 0))
        end_time = datetime.fromtimestamp(sleep_data.get("endDt", 0))
        
        # 총 수면 시간 계산 (초)
        total_sleep = (
            sleep_data.get("deepsleep_duration", 0) + 
            sleep_data.get("lightsleep_duration", 0) + 
            sleep_data.get("remsleep_duration", 0)
        )
        
        # 결과 형식화
        result = f"{date_str} 수면 데이터 분석:\n\n"
        result += f"수면 점수: {sleep_data.get('sleep_score', 0)}/100\n"
        result += f"수면 시간: {start_time.strftime('%H:%M')} ~ {end_time.strftime('%H:%M')}\n"
        result += f"총 수면 시간: {self._format_duration(total_sleep)}\n\n"
        
        # 수면 단계별 시간
        result += "수면 단계:\n"
        result += f"- 깊은 수면: {self._format_duration(sleep_data.get('deepsleep_duration', 0))} "
        result += f"({(sleep_data.get('deepsleep_duration', 0) / total_sleep * 100):.1f}%)\n"
        
        result += f"- 얕은 수면: {self._format_duration(sleep_data.get('lightsleep_duration', 0))} "
        result += f"({(sleep_data.get('lightsleep_duration', 0) / total_sleep * 100):.1f}%)\n"
        
        result += f"- REM 수면: {self._format_duration(sleep_data.get('remsleep_duration', 0))} "
        result += f"({(sleep_data.get('remsleep_duration', 0) / total_sleep * 100):.1f}%)\n\n"
        
        # 심박수 및 호흡 데이터
        result += "생체 데이터:\n"
        result += f"- 평균 심박수: {sleep_data.get('hr_average', 0)}bpm (최소: {sleep_data.get('hr_min', 0)}, 최대: {sleep_data.get('hr_max', 0)})\n"
        result += f"- 평균 호흡수: {sleep_data.get('rr_average', 0)}/분 (최소: {sleep_data.get('rr_min', 0)}, 최대: {sleep_data.get('rr_max', 0)})\n"
        result += f"- 호흡 곤란 지수: {sleep_data.get('breathing_disturbances_intensity', 0)}/100\n"
        
        # 코골이 데이터가 있는 경우
        if "snoring" in sleep_data and sleep_data.get("snoring", 0) > 0:
            result += f"- 코골이 시간: {self._format_duration(sleep_data.get('snoring', 0))}\n"
            result += f"- 코골이 횟수: {sleep_data.get('snoring_episode_count', 0)}회\n"
        
        return result
    
    async def _get_recent_weekly_data(self, user_id: str) -> str:
        """
        사용자의 최근 주간 집계 데이터를 조회합니다.
        
        Args:
            user_id: 사용자 ID
            
        Returns:
            str: 최근 주간 데이터 문자열
        """
        # 최근 주간 데이터 조회
        weekly_data = await self.processing_sleep_collection.find_one(
            {"id": user_id, "aggregation_type": "weekly"},
            sort=[("week_number", -1)]
        )
        
        if not weekly_data:
            return f"최근 주간 수면 데이터를 찾을 수 없습니다. (사용자 ID: {user_id})"
        
        # 결과 형식화
        result = f"{weekly_data.get('week_number', '알 수 없는 주차')} 주간 수면 데이터 분석:\n\n"
        result += f"평균 수면 점수: {weekly_data.get('avg_sleep_score', 0)}/100\n"
        result += f"평균 수면 시간: {self._format_duration(weekly_data.get('avg_sleep_time', 0))}\n\n"
        
        # 수면 단계별 시간
        result += "평균 수면 단계:\n"
        result += f"- 깊은 수면: {self._format_duration(weekly_data.get('avg_deep_sleep', 0))}\n"
        result += f"- 얕은 수면: {self._format_duration(weekly_data.get('avg_light_sleep', 0))}\n"
        result += f"- REM 수면: {self._format_duration(weekly_data.get('avg_rem_sleep', 0))}\n"
        
        return result