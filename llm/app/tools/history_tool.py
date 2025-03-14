import re
from app.db.chat_repository import get_recent_history

def query_history(input_str: str) -> str:
    """
    입력된 프롬프트에서 사용자 ID를 추출하고,
    해당 사용자의 최근 대화 내역을 조회하여 반환합니다.
    
    Args:
        input_str (str): Agent에서 전달받은 프롬프트 문자열.
        
    Returns:
        str: 최근 대화 내역에 대한 요약 문자열 또는 에러 메시지.
    """
    
    print("agent로부터 받은 쿼리: ", input_str)
    
    # 사용자 ID 추출 (예: "사용자 ID: abc123")
    match = re.search(r"\s*(\S+)", input_str)
    if not match:
        return "'사용자 ID가 query_history에 도달하지 않았음'을 답변으로 출력해주세요."
    user_id = match.group(1)
    
    print("by_query_history:", user_id)
    
    # chat_repository에 정의된 get_recent_history() 함수를 사용하여 최근 대화 내역 조회
    history = get_recent_history(user_id)
    
    if not history:
        return f"사용자 {user_id}의 최근 대화 내역이 없습니다."
    
    # history가 리스트라면, 각 항목을 줄바꿈으로 연결
    if isinstance(history, list):
        history_summary = "\n\n".join(history)
    else:
        history_summary = str(history)
    
    return f"사용자 {user_id}의 최근 대화 내역:\n{history_summary}"
