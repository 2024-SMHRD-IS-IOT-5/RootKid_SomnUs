import re
from langchain_community.chat_models import ChatOpenAI
from langchain.prompts import PromptTemplate

from app.db.database import get_database
from app.core.config import API_KEY

# LLM을 활용해 질문에 따른 필요한 DB 필드를 결정하는 LLM 인스턴스 생성
llm_field_selector = ChatOpenAI(model="gpt-3.5-turbo", temperature=0, openai_api_key=API_KEY)

# 프롬프트 템플릿: 사용자의 질문을 바탕으로 필요한 필드를 JSON 형식(리스트)으로 반환하도록 유도
field_selector_prompt = PromptTemplate(
    input_variables=["question"],
    template="""
    사용자의 질문을 보고, 수면 데이터에서 어떤 필드가 필요한지 JSON 형식으로 반환해줘.
    가능한 필드 및 설명:
    - "id": 사용자 ID
    - "date": 날짜
    - "startDt": 수면 시작 시각(Unix time)
    - "endDt": 수면 종료 시각(Unix time)
    - "lightsleepduration": 얕은 수면 시간
    - "deepsleepduration": 깊은 수면 시간
    - "wakeupcount": 일어난 횟수
    - "remsleepduration": 렘 수면 시간
    - "hr_average": 평균 심박수
    - "hr_min": 최저 심박수
    - "hr_max": 최고 심박수
    - "rr_average": 평균 호흡횟수
    - "rr_min": 최저 호흡횟수
    - "rr_max": 최고 호흡횟수
    - "breathing_disturbances_intensity": 호흡 곤란 횟수
    - "snoring": 코를 곤 시간
    - "snoringepisodecount": 코를 곤 횟수
    - "sleep_score": 수면 점수
    
    예시:
    질문: "어제 내 수면 시간과 점수를 알려줘"
    출력: ["startDt", "endDt", "sleep_score"]
    질문: "내가 요즘 코를 많이 골았나?"
    출력: ["snoringepisodecount"]
    질문: "혹시 나 수면 무호흡증 증세가 있니?"
    출력: ["breathing_disturbances_intensity"]
    질문: "{question}"
    출력:
    """
)

def get_required_fields(question: str):
    """
    사용자의 질문을 바탕으로 LLM을 통해 필요한 필드를 결정하고,
    JSON 형식의 리스트로 반환합니다.
    """
    response = llm_field_selector.invoke(field_selector_prompt.format(question=question))
    
    try:
        # 응답 문자열을 리스트로 변환 (JSON 형식의 문자열이어야 함)
        required_fields = eval(response)  # 실제 배포 시에는 json.loads()를 사용하는 것이 더 안전합니다.
        if isinstance(required_fields, list):
            return required_fields
        else:
            return []
    except Exception as e:
        return []

def query_db(input_str: str) -> str:
    """
    입력된 프롬프트에서 사용자 ID와 질문,날짜 정보를 추출한 후,
    LLM을 통해 필요한 필드를 결정하고, 해당 필드만 MongoDB에서 조회합니다.
    
    Args:
        input_str (str): Agent로부터 전달받은 프롬프트 문자열.
        
    Returns:
        str: 선택된 필드들로 구성된 수면 데이터 요약 결과.
    """
    print("agent로부터 받은 쿼리: ", input_str)
    
    # 1. 사용자 ID 추출
    match = re.search(r"\s*(\S+)", input_str)
    if not match:
        return "사용자 ID를 찾을 수 없습니다."
    user_id = match.group(1)
    
    # 2. 질문 추출 (예: "질문: 내 어제 수면 점수는?" 형태)
    question_match = re.search(r"\s*(.+)", input_str)
    question = question_match.group(1).strip() if question_match else ""
    
    # 3. LLM을 통해 필요한 DB 필드 결정
    required_fields = get_required_fields(question)
    if not required_fields:
        return "질문에서 필요한 데이터를 파악하지 못했습니다."
    
    # 4. 선택적으로 날짜 필터 추출 (예: "날짜: 2024-03-12")
    date_match = re.search(r"\s*(\d{4}-\d{2}-\d{2})", input_str)
    date_filter = date_match.group(1) if date_match else None
    
    # 5. MongoDB에서 조회
    db = get_database()
    collection = db.get_collection("processing_sleep")
    
    query = {"id": user_id}
    if date_filter:
        query["date"] = date_filter

    # projection: 필요한 필드만 선택, _id는 제외
    projection = {field: 1 for field in required_fields}
    projection["_id"] = 0

    result = collection.find_one(query, projection=projection, sort=[("date", -1)])
    print("db_tool에서 찾음: ",result)
    
    if result:
        return f"사용자 {user_id}의 요청된 수면 데이터: {result}"
    else:
        return f"사용자 {user_id}의 수면 데이터를 찾을 수 없습니다."
