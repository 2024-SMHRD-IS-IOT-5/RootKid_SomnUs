import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
from datetime import datetime,timedelta

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")
llm = ChatOpenAI(model_name="gpt-3.5-turbo", openai_api_key=api_key)

utc_now = datetime.now()
kst_now = utc_now + timedelta(hours=9)

async def weekly_report_process(sleep_data):
    """수면 정보를 분석하여 주간 리포트에 들어갈 내용을 return"""
    print("지금시각: ", kst_now.strftime("%Y-%m-%d %H:%M:%S KST"))

    