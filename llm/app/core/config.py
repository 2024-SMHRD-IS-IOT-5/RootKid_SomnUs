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
chat_config = {
    "openai_api_key": API_KEY,
    "agent_model": "gpt-4"
}