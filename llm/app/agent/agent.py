import os
from langchain.agents import initialize_agent, AgentType
from langchain.chat_models import ChatOpenAI
from langchain.tools import Tool

from app.tools.db_tool import query_db
from app.tools.history_tool import query_history
from app.tools.rag_tool import query_rag
from app.core.config import API_KEY


llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0, openai_api_key=API_KEY)

# Agent가 사용할 도구(Tool) 정의
tools = [
    Tool(
        name="DB Tool",
        func=query_db,
        description="사용자의 개인 수면 데이터를 조회합니다. (사용자 ID와 관련된 수면 데이터를 반환)"
    ),
    Tool(
        name="History Tool",
        func=query_history,
        description="최근 대화 내역을 기반으로 답변을 생성합니다. 이전 대화 맥락을 제공합니다."
    ),
    Tool(
        name="RAG Tool",
        func=query_rag,
        description="수면 관련 일반 정보를 검색합니다. 학술 자료 등에서 정보를 가져옵니다."
    )
]

# ReAct 
# Reasoning + Acting 으로, 
# 질문을 이해하고, 논리적으로 추론한 뒤, 적절한 도구를 실행한다는 말임.
# Zero-Shot ReAct
# 이번에 사용할 ReAct 타입.
# 에이전트가 사전 학습 없이 즉석으로(Zero-Shot) ReAct하는 방식.
# 다른 방식으로는 Few-Shot이 있는데,
# 도구 선택을 위한 몇 가지 예제를 제공하는 방식이다.
# Zero-Shot 은 더 빠르고, Few-Shot은 더 정확함.
# 일단 Zero-Shot으로 먼저 사용해보고, 정확성이 떨어진다면 Few-Shot을 사용해보자.
# 다만, 채팅은 응답속도도 중요하기에 속도와 정확성의 밸런싱도 중요한 문제다.


# Agent 초기화
agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True,
)

def run_agent(user_id: str, question: str, user_type: str) -> str:
    """
    사용자 ID, 질문, 그리고 사용자 유형(학생/학부모)을 받아 Agent를 실행함.
    Agent는 입력된 정보를 바탕으로 적절한 도구를 선택하여 실행하고 결과를 반환함.
    
    Args:
        user_id (str): 사용자 ID
        question (str): 사용자의 질문
        user_type (str): 사용자 유형 ("학생" 또는 "학부모")
        
    Returns:
        str: Agent가 생성한 응답
    """
    # 사용자 컨텍스트를 포함한 프롬프트 구성
    combined_prompt = (
        f"사용자 ID: {user_id}\n"
        f"질문: {question}\n"
        "위 정보를 바탕으로 적절한 도구를 선택하여 답변을 제공해줘."
    )
    
    # Agent 실행: 입력된 프롬프트에 따라 필요한 도구를 호출하고 응답 생성
    result = agent.run(combined_prompt)
    return result
