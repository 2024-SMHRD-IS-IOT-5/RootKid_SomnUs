import sys
import os

# docker가 위치 인식을 못해서 이렇게 설정해줘야 한단다.
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/../..")  # '/app'을 경로에 추가

from app.services.chat_service import chatbot
from app.db.chat_repository import save_chat

# 질문 받기
question = input()
response = chatbot(question).content

print(response)

# 질문,응답 DB에 넣기
save_chat(question, response)