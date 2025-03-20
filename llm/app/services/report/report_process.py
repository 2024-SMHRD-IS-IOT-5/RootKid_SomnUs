import os
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate

from app.core.config import API_KEY

llm = ChatOpenAI(model_name="gpt-4", openai_api_key=API_KEY, temperature=0.5)

async def report_to_template(comment:str):
    """작성한 리포트의 멘트를 다듬어서 return"""
    
    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(
            """
            당신은 리포트를 작성하는 전문가입니다.
            사용자가 제공하는 리포트 내용을 읽기 쉽고 친근하게 다듬어주세요.

            지침:
            1. 모든 문장을 사용자가 읽기 쉽게 다듬어주세요.
            2. 수치 데이터를 사용자 친화적으로 변환하세요:
            - 100단위 이상의 초 단위는 시간/분 단위로 변환 (예: 3600초 → 1시간)
            3. 학생을 대상으로 하는 친근하고 격려하는 말투를 사용하세요.
            4. 월간 리포트의 경우 핵심 내용을 5~6줄로 요약하세요.
            5. 중요한 성과나 개선점은 강조해서 표현하세요.
            6. 필요시 제목과 소제목을 사용하여 구조화하세요.
            """
        ),
        HumanMessagePromptTemplate.from_template(
            """
            {comment}
            """
        )
    ])
    
    chain = prompt | llm
    result = chain.invoke({"comment":comment})
    
    return result.content