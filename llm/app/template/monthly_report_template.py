def monthly_report_template(month_info, week_info, comments):
    
    month_template = f"""
    이번 달의 수면 데이터를 바탕으로 보고서를 작성해 주세요.\n
    
    다음은 이번 달의 종합 정보입니다:
    시간 정보: {month_info["month_number"]},
    평균 깊은 수면 시간: {month_info["avg_deep_sleep"]},
    평균 얕은 수면 시간: {month_info["avg_light_sleep"]},
    평균 렘 수면 시간: {month_info["avg_rem_sleep"]},
    평균 수면 점수: {month_info["avg_sleep_score"]},
    평균 수면 시간: {month_info["avg_sleep_time"]}
    """
    
    week_template= f"""
    다음은 이번 달의 주간 종합 데이터를 dict형태로 담은 list입니다.
    <key 설명>
    "week_number" : 주차 정보(예s시: 2025-02-W2: 2025년 2월 2주차),
    "avg_deep_sleep" : 평균 깊은 수면 시간,
    "avg_light_sleep" : 평균 얕은 수면 시간,
    "avg_rem_sleep" : 평균 렘 수면 시간,
    "avg_sleep_score" : 평균 수면 점수,
    "avg_sleep_time" : 평균 수면 시간
    <데이터>
    {week_info}
    """
    
    comments= f"""
    다음은 이번 달 주간 리포트에 작성된 내용들입니다.
    세 개의 개요로 나누어져 있으며,
    각각 주간 요약, 이번주 특이사항, 개선사항입니다.
    {comments}
    """
    
    description = """
    위 데이터를 종합하여 이번달의 리포트를 작성해 주세요.
    리포트에 들어갈 내용은 한 달 동안의 종합적인 평가입니다.
    특이사항에 대한 내용이나, 주차별 변화 등을 다루면 좋습니다.
    """
    
    template = month_template + week_template + comments + description
    return template