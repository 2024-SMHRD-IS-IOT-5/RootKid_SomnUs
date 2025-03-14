import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
import json

from app.db.database import db
from app.template.weekly_report_template import weekly_report_template

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")
llm = ChatOpenAI(model_name="gpt-4", openai_api_key=api_key)
    
async def weekly_template_build(sleep_data):
    """수면 정보를 받아 조건에 맞는 데이터를 db에서 검색 후 템플릿 return"""
    week = sleep_data["week_number"]
    id = sleep_data["id"]
    week_data = await db.sleep.find({"week_number":week, "id":id}, {"_id": 0, "id": 0}).to_list(length=None)
    count = len(week_data)
    template = weekly_report_template(
        week_info=sleep_data,
        day_info=json.dumps(week_data, ensure_ascii=False),
        count = count)
    return template
    

async def weekly_report_process(sleep_data):
    """수면 정보를 분석하여 주간 리포트에 들어갈 내용을 return"""
    
    template = await weekly_template_build(sleep_data)
    template_escaped = template.replace("{","{{").replace("}","}}")
    
    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(
            """
            당신은 사용자의 수면 데이터를 분석하여 리포트를 작성하는 의사입니다..
            데이터를 기반으로 건강한 수면습관을 형성하고자 하는 청소년들을 위해 친절한 어투를 사용해서 리포트를 작성해 주세요.
            리포트의 개요는 한 주에 대한 요약, 이번 주 특이사항, 개선사항으로 나뉩니다.
            각 항목들을 인덱스로 하는 리스트로 답변을 작성해줘.
            예시: [한 주에 대한 요약, 이번 주 특이사항, 개선사항]
            """
        ),
        HumanMessagePromptTemplate.from_template("{content}")
    ])
    
    chain = prompt | llm
    result = await chain.ainvoke({"content":template_escaped})
    
    print(result.content)
    return result.content
    
    