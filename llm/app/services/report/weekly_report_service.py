import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate

from app.db.database import db
from app.template.weekly_report_template import weekly_report_template

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")
llm = ChatOpenAI(model_name="gpt-3.5-turbo", openai_api_key=api_key)
    
async def weekly_data_process(sleep_data):
    """수면 정보를 받아 조건에 맞는 데이터를 db에서 검색 후 템플릿 작성"""
    week = sleep_data["week_number"]
    week_data = await db.sleep.find({"week_number":week}).to_list(length=None)
    template = weekly_report_template(week_info=sleep_data,day_info=week_data)
    return template
    

async def weekly_report_process(sleep_data):
    """수면 정보를 분석하여 주간 리포트에 들어갈 내용을 return"""
    
    result = await weekly_data_process(sleep_data)
    week = sleep_data["week_number"]
    
    