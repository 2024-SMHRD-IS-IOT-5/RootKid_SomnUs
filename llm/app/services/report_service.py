import os
from langchain.chains import LLMChain
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")

llm = ChatOpenAI(model_name="gpt-3.5-turbo", openai_api_key=api_key)

sleep_data = {
    "_id": {
        "$oid": "67cea2a4a46ca4a466eb7fff"
    },
    "id": "smhrd",
    "date": "2025-02-24",
    "startDt": 1598885940,
    "endDt": 1598908800,
    "lightsleep_duration": 8760,
    "deepsleep_duration": 4740,
    "wakeup_count": 1,
    "remsleep_duration": 7440,
    "hr_average": 70,
    "hr_min": 58,
    "hr_max": 94,
    "rr_average": 15,
    "rr_min": 12,
    "rr_max": 23,
    "breathing_disturbances_intensity": 8,
    "snoring": 0,
    "snoring_episode_count": 0,
    "sleep_score": 61,
    "week_number": "2025-02-W4",
    "month_number": "2025-02"
    }

# 일간 리포트 멘트 작성 함수
def daily_report_process():
  """ 수면 정보를 분석하여 일간 리포에 들어갈 내용을 return"""
  
  sleep_info = {
      "date": sleep_data.get("date"),
      "sleep_score": sleep_data.get("sleep_score"),
      "wakeup_count": sleep_data.get("wakeup_count"),
      "lightsleep_duration": sleep_data.get("lightsleep_duration"),
      "deepsleep_duration": sleep_data.get("deepsleep_duration"),
      "remsleep_duration": sleep_data.get("remsleep_duration"),
      "breathing_disturbances_intensity": sleep_data.get("breathing_disturbances_intensity"),
  }
  
  prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
      "너는 사용자의 수면 데이터를 분석하여 리포트를 작성하는 AI 전문가야."
      "데이터를 기반으로 건강한 건강한 수면습관을 키우고자 하는 청소년을 위해 친절하게 평가를 해줘."
    ),
      HumanMessagePromptTemplate.from_template(
          "오늘 날짜 {date}의 수면 데이터를 바탕으로 한줄 평가를 작성해줘.\n"
          "수면 점수: {sleep_score}\n"
          "깨어난 횟수: {wakeup_count}\n"
          "Light 수면 지속 시간: {lightsleep_duration}초\n"
          "Deep 수면 지속 시간: {deepsleep_duration}초\n"
          "REM 수면 지속 시간: {remsleep_duration}초\n"
          "호흡 장애 강도: {breathing_disturbances_intensity}\n\n"
          "위 데이터를 종합하여 오늘의 전반적인 수면을 한 문장으로 평가해줘.\n"
          "그리고 언급할만한 특이사항이 있다면 그것도 한 문장으로 적어줘."
      )
    ])
  
  chain = prompt | llm
  result = chain.invoke(sleep_info)
  
  return result.content