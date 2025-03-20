import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")
llm = ChatOpenAI(model_name="gpt-3.5-turbo", openai_api_key=api_key)


# 일간 리포트 멘트 작성 함수
async def daily_report_process(sleep_data):
  """ 수면 정보를 분석하여 일간 리포트에 들어갈 내용을 return"""
  
  sleep_info = {
      "date": sleep_data["date"],
      "sleep_score": sleep_data["sleep_score"],
      "wakeup_count": sleep_data["wakeup_count"],
      "lightsleep_duration": sleep_data["lightsleep_duration"],
      "deepsleep_duration": sleep_data["deepsleep_duration"],
      "remsleep_duration": sleep_data["remsleep_duration"],
      "breathing_disturbances_intensity": sleep_data["breathing_disturbances_intensity"],
  }
  
  prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
      "너는 사용자의 수면 데이터를 분석하여 리포트를 작성하는 의사야."
      "데이터를 기반으로 건강한 수면습관을 키우고자 하는 청소년을 위해 친절하게 평가를 해줘."
    ),
      HumanMessagePromptTemplate.from_template(
          "오늘 날짜 {date}의 수면 데이터를 바탕으로 한줄 평가를 작성해줘.\n"
          "수면 점수: {sleep_score}\n"
          "깨어난 횟수: {wakeup_count}\n"
          "얕은 수면 지속 시간: {lightsleep_duration}초\n"
          "깊은 수면 지속 시간: {deepsleep_duration}초\n"
          "렘 수면 지속 시간: {remsleep_duration}초\n"
          "호흡 곤란 횟수: {breathing_disturbances_intensity}\n\n"
          "위 데이터를 종합하여 오늘의 전반적인 수면을 한 문장으로 평가해줘.\n"
          "그리고 언급할만한 특이사항이 있다면 그것도 한 문장으로 적어줘.\n"
          "특히 특이사항에 대한 개선 방향도 구체적으로 알려줘\n"
          "청소년들을 위해 친구같은 친근한 어투를 사용해줘."
      )
    ])
  
  chain = prompt | llm
  result = chain.invoke(sleep_info)
  
  return result.content