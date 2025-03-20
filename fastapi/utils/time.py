from datetime import datetime, timedelta
import re

def get_monthly_week(date_str, numeric: bool = False):
    """해당 날짜(YYYY-MM-DD)가 속한 월의 주차를 계산 (이전 달 주차를 완전히 채운 후 시작)"""
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    first_day_of_month = datetime(date_obj.year, date_obj.month, 1)

    # 월의 첫 번째 월요일 찾기
    first_monday = first_day_of_month
    while first_monday.weekday() != 0:  # 0 = 월요일
        first_monday += timedelta(days=1)

    # 첫 번째 월요일이 나오기 전까지는 이전 달의 마지막 주차 유지
    if date_obj < first_monday:
        previous_month = first_day_of_month - timedelta(days=1)
        return f"{previous_month.year}-{previous_month.month:02d}-W{get_week_number(previous_month)}"

    # 주차 계산 (첫 월요일부터 시작)
    delta_days = (date_obj - first_monday).days
    week_number = (delta_days // 7) + 1

    return f"{date_obj.year}-{date_obj.month:02d}-W{week_number}"

def get_week_number(date_obj: datetime) ->str:
    """주어진 날짜의 주차 반환 (월요일을 기준)"""
    first_day_of_month = datetime(date_obj.year, date_obj.month, 1)

    # 월의 첫 번째 월요일 찾기
    first_monday = first_day_of_month
    while first_monday.weekday() != 0:  # 0 = 월요일
        first_monday += timedelta(days=1)

    # 주차 계산
    delta_days = (date_obj - first_monday).days
    return (delta_days // 7) + 1

def get_month(date_str: str, numeric: bool = False) -> str:
    """
    해당 날짜(YYYY-MM-DD)가 속한 월을 반환.
    numeric이 True이면 'YYYY-MM' 형식으로 반환하고,
    numeric이 False이면 'YYYY년 MM월' 형식으로 반환.
    """
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    if numeric:
        return f"{date_obj.year}-{date_obj.month:02d}"
    else:
        return f"{date_obj.year}년 {date_obj.month:02d}월"


def format_seconds(seconds):
    """초 단위를 'X시간 Y분' 형식으로 변환"""
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    if hours > 0:
        return f"{hours}시간 {minutes}분" if minutes > 0 else f"{hours}시간"
    return f"{minutes}분"

def format_time(timestamp):
    """Unix timestamp -> HH : MM 형식으로 변환"""
    return datetime.fromtimestamp(timestamp).strftime('%H:%M')

def format_week_number(week_number: str) -> str:
    try:
        year, month, week = week_number.split("-")  # 예: ["2025", "02", "W4"]
        week = week.lstrip("W")  # "W4" -> "4"
        year_short = year[2:]   # "2025" -> "25"
        month_int = int(month)  # "02" -> 2
        return f"{year_short}년 {month_int}월 {week}주차"
    except Exception as e:
        # 변환 실패 시 원래 값을 반환
        return week_number

def convert_flutter_week_to_db_format(date: str) -> str:
    """
    Flutter에서 전달된 주차 문자열(예: "3월 3주차")를 데이터베이스 형식("YYYY-MM-W3")으로 변환.
    """
    match = re.match(r'(\d{1,2})월\s*(\d{1,2})주차', date)
    if not match:
        raise ValueError(f"Invalid date format: {date}.")
    month = int(match.group(1))
    week = int(match.group(2))
    year = datetime.today().year
    return f"{year}-{month:02d}-W{week}"

def get_monday_date_from_flutter_week(date: str) -> datetime:
    """
    Flutter에서 전달된 주차 문자열(예: "3월 3주차")를 기반으로 해당 주의 월요일 날짜를 계산합니다.
    W1은 해당 월의 첫 번째 월요일을 기준으로 합니다.
    """
    match = re.match(r'(\d{1,2})월\s*(\d{1,2})주차', date)
    if not match:
        raise ValueError(f"Invalid date format: {date}. Expected format like '3월 3주차'")
    month = int(match.group(1))
    week = int(match.group(2))
    year = datetime.today().year
    # 해당 월의 첫 날
    first_day = datetime(year, month, 1)
    # 첫 월요일 찾기 (만약 1일이 월요일이면 그대로, 아니면 이후 첫 월요일)
    first_monday = first_day if first_day.weekday() == 0 else first_day + timedelta(days=(7 - first_day.weekday()))
    # 선택한 주차의 월요일 계산 (week-1: 첫 월요일이 W1)
    monday_date = first_monday + timedelta(days=7 * (week - 1))
    return monday_date

def convert_calander_date(date_str: str) -> str:
    """
    Flutter에서 전달된 날짜 문자열(예: "2025.03")을 "YYYY-MM-" 형식으로 변환합니다.
    예: "2025.03" -> "2025-03-"
    """
    try:
        parts = date_str.split(".")
        if len(parts) != 2:
            raise ValueError("날짜 형식이 올바르지 않습니다. 예: '2025.03'")
        year = parts[0].strip()
        month = parts[1].strip().zfill(2)  # 두 자리 숫자로 보장
        return f"{year}-{month}-"
    except Exception as e:
        raise ValueError(f"날짜 변환 오류: {e}")
