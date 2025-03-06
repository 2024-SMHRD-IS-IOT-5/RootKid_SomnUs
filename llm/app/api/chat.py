# import sys
import os
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
import httpx
import json

from app.services.chat_service import chatbot
from app.db.chat_repository import save_chat
from app.core.config import FASTAPI_SERVER_URL

# docker가 위치 인식을 못해서 이렇게 설정해줘야 한단다.
# sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/../..")  # '/app'을 경로에 추가

router = APIRouter()

class ChatMessageRequest(BaseModel):
    message: str

class ChatMessageResponse(BaseModel):
    response: str

@router.post("", response_model=ChatMessageResponse)
async def chat_message(request: Request, payload: ChatMessageRequest):
    # 클라이언트의 IP 주소를 출력
    client_host = request.client.host
    print("Received message from", client_host, ":", payload.message)
    
    test_response = "LLM 서버가 메시지를 받음!"
    return ChatMessageResponse(response=test_response)

# @router.post("/chatbot/message")
# async def receive_message(data: dict):
#     """FastAPI 서버에서 받은 사용자 메시지를 처리하고 응답 반환"""
#     message = data.get("message", "")
    
#     # ✅ 메시지를 수신했는지 로그로 출력
#     print(f"챗봇 서버가 메시지를 받음: {message}")

#     if not message:
#         raise HTTPException(status_code=400, detail="메시지가 비어있음")

#     # 🎯 여기에서 LangChain을 활용한 챗봇 응답 생성 (예제)
#     chatbot_response = "LLM서버에서 메세지 성공적으로 받음."
    
#     return {"response": chatbot_response}



# # 질문 받기
# response = chatbot(question).content

# print(response)

# # 질문,응답 DB에 넣기
# save_chat(question, response)