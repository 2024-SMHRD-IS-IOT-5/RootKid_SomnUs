import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
import json

from app.db.database import db
from app.template.weekly_report_template import weekly_report_template
from app.core.config import API_KEY

llm = ChatOpenAI(model_name="gpt-4", openai_api_key=API_KEY, temperature=1)
    
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
            한 주에 대한 요약은 이번주 수면 데이터에 대한 전체적인 평가를 내립니다. 자세하게 분석하기보단, 전체적인 평가를 내려주세요.
            특이사항은 언급할만한 패턴 변화나 특징점이 있는 데이터를 중심으로 작성해주세요.
            개선 사항은 한 주에 대한 요약과 특이사항에서 언급한 것들에 대한 개선 방향을 중심으로 작성해주세요.
            각 항목들을 인덱스로 하는 리스트로 답변을 작성해 주세요.
            예시: [한 주에 대한 요약, 이번 주 특이사항, 개선사항]
            """
        ),
        HumanMessagePromptTemplate.from_template("{content}")
    ])
    
    chain = prompt | llm
    result = await chain.ainvoke({"content":template_escaped})
    
    # 저장하기 좋게 리스트로 바꿔주기
    def result_process(s):
        s = s.replace("\n", "")
        s = s.replace("한 주에 대한 요약: ", "")
        s = s.replace("이번 주 특이사항: ", "")
        s = s.replace("개선사항: ", "")
        return s
    result = result_process(result.content)
    # print("변환한 리스트: ",result)
    print("주간 리포트 초안: ", result)
    
    return result
    
    