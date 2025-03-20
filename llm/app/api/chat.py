# import sys
import os
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel

from app.services.chat_service import chatbot
from app.db.chat_repository import save_chat

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
    message = payload.message
    print("Received message from", client_host, ":", message)
    
    response = chatbot(question=message)
    print(response)
    
    # 질문, 응답 DB에 넣기
    await save_chat(message,response)
    
    return ChatMessageResponse(response=response)