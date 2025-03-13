from app.agent.agent import run_agent
from app.db.chat_repository import save_chat

def process_chat(question:str, user_id: str, user_type: str) -> str:
    """
    사용자의 질문을 받아 Langchain Agent를 실행하고 응답을 반환함.

    Args.:
        question(str): 사용자 입력 프롬프트
        userid(str): 사용자 식별자
        usertype(str): 사용자 타입

    Returns:
        str: Agent가 생성한 최종 응답
    """

    # Agent 실행: 프롬프트를 전달하여 도구 선택 및 실행 후 결과 받기
    response = run_agent(userid = user_id, question = question, user_type = usertype)
    
    # 대화 내역 저장: 실패 시 로그 출력
    try:
        save_chat(userid = user_id, question = question, usertype = user_type)
    except Exception as e:
        print(f"대화 내역 저장 실패: {str(e)}")
    
    return response