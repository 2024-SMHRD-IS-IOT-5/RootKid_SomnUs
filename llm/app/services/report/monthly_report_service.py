import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
import json

from app.db.database import db
from app.template.monthly_report_template import monthly_report_template

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")
llm = ChatOpenAI(model_name="gpt-4", openai_api_key=api_key)

async def monthly_template_build(sleep_data):
    """ 수면 정보를 받아 조건에 맞는 데이터를 db에서 검색 후 템플릿 return"""

    month = sleep_data["month_number"]
    id = sleep_data["id"]

    # 해당 월의 주간 데이터 추출
    week_data = await db.processing_sleep.find(
        {"id":id, "month_number":month, "aggregation_type":"weekly"},
        {"_id":0, "aggregation_type":0, "id":0}
    ).to_list(length=None)
    
    # 해당 월의 주차 추출
    weeks = []
    for i in week_data:
        weeks.append(i["week_number"])
    
    # 해당 주차의 보고서 내용 추출
    comments = await db.reports.find(
        {"id":id, "date":{"$in":weeks}},
        {"_id":0, "id":0, "timestamp":0}
    ).to_list(length=None)
    
    # 템플릿 작성 함수 실행
    template = monthly_report_template(
        month_info=sleep_data,
        week_info=json.dumps(week_data, ensure_ascii=False),
        comments=json.dumps(comments, ensure_ascii=False)
    )
    return template
    


async def monthly_report_process(sleep_data):
    """수면 정보를 분석하여 월간 리포트에 들어갈 내용을 return"""

    template = await monthly_template_build(sleep_data)
    template_escaped = template.replace("{","{{").replace("}","}}")
    
    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(
            """
            당신은 사용자의 수면 데이터를 분석하여 리포트를 작성하는 의사입니다..
            데이터를 기반으로 건강한 수면습관을 형성하고자 하는 청소년들을 위해 친절한 어투를 사용해서 리포트를 작성해 주세요.
            한 달 동안의 데이터를 바탕으로 종합적인 평가를 내려주세요.
            특히, 특이사항에 대해서 설명해주세요.
            길이는 4 문장으로 제한합니다.
            """
        ),
        HumanMessagePromptTemplate.from_template("{content}")
        ])
    
    chain = prompt | llm
    result = await chain.ainvoke({"content":template_escaped})
        
    print(result.content)
    return result.content