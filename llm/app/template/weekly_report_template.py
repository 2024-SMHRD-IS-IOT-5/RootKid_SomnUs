def weekly_report_template(week_info, day_info):
    count = len(day_info)
    
    week_template = f"""
    이번주의 수면 데이터를 바탕으로 보고서를 작성해줘.\n
    이번주 측정 횟수: {count},
    평균 깊은 수면 시간: {week_info["avg_deep_sleep"]},
    평균 얕은 수면 시간: {week_info["avg_light_sleep"]},
    평균 렘 수면 시간: {week_info["avg_rem_sleep"]},
    평균 수면 점수: {week_info["avg_sleep_score"]},
    평균 수면 시간: {week_info["avg_sleep_time"]}
    \n\n
    """
    
    day_template= f"""
    다음은 이번주의 일일 데이터를 dict형태로 담은 list입니다.
    <key 설명>
    date : 오늘 날짜,
    sleep_score : 수면 점수,
    wakeup_count : 깨어난 횟수,
    lightsleep_duration : 얕은 수면 지속 시간
    deepsleep_duration : 깊은 수면 지속 시간
    remsleep_duration : 렘 수면 지속 시간
    'hr_average': 심박수 평균, 
    'hr_min': 최소 심박수,
    'hr_max': 최대 심박수,
    'rr_average': 평균 호흡 횟수,
    'rr_min': 최소 호흡 횟수,
    'rr_max': 최대 호흡 횟수,
    breathing_disturbances_intensity : 호흡 곤란 횟수
    {day_info}
    """
    
    description = """
    위 데이터를 종합하여 이번주의 리포트를 작성해줘.
    리포트에 들어갈 내용은
    """
    
    template = week_template + day_template + description
    
    
    return "Hi"