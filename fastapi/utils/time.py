from datetime import datetime, timedelta

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
