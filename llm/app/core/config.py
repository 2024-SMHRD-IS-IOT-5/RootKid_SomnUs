import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

# MongoDB 설정
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

# API KEY
API_KEY = os.getenv("OPENAI_API_KEY")
LANGSMITH_API_KEY = os.getenv("LANGSMITH_API_KEY")

# 서버 연결 설정
FASTAPI_SERVER_URL=os.getenv("FASTAPI_SERVER_URL")
LLM_SERVER_URL=os.getenv("LLM_SERVER_URL")
TEST_SERVER_URL=os.getenv("TEST_SERVER_URL")

# chatbot용 config
chatbot_config = {
    # 기본 설정
    "openai_api_key": API_KEY,
    "agent_model": "gpt-4",
    "agent_temperature": 0.2,
    "agent_max_tokens": 1500,
    
    # 에이전트 실행 설정
    "verbose": False,
    "max_iterations": 3,
    "max_execution_time": 20,
    
    # MongoDB 연결 설정
    "db_connection_string": MONGO_URI,
    "db_name": DB_NAME,
}