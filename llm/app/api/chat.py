#  <<<챗봇 구현하기>>>

# 프롬프트를 받으면, 우선 이것을 검증.
# 여기서 ai agent를 사용.
# llm 하나로 이 자연어가 어느 tool을 사용해야하는지 검증해 보는거지.
# 그 다음, 선택한 tool로 프롬프트를 넣음.
# 여기까지 성공하는 것이 1단계.

# 2단계는 각각의 tool들을 완성시켜야 함.
# 여기는 세부적으로 나뉨.
# - vector embedding을 이용하는 tool은 학술자료를 검색해서 소스로서 넣어야함.
# - db를 참조하는 tool은 쿼리를 작성하는 하위 tool을 만들어야 할 수도 있음.
# - 채팅 내역 참조도 마찬가지

# 3단계는 템플릿 작성임.
# tool을 불러오고 나서, 답변이 어떤 온도고, 어떤 템플릿이고, 그런 것들을 조정함.

# 4단계는 테스트.
# 완성본이 챗봇으로서 충분히 기능하고 있는지, 불러오는 속도는 어떤지를 테스트함.

"""
chat.py

이 모듈은 FASTAPI의 엔드포인트를 생성, /chat/message 엔드포인트로 요청을 받음.

user_id, prompt가 없으면 에러 반환.

메시지, 유저 아이디, 유저 구분을 chat_service에 전달하여 처리.

Agent실행 결과를 return.

"""

from fastapi import APIRouter, HTTPException
from app.services.chat.chat_service import process_chat
from pydantic import BaseModel

router = APIRouter()

class ChatMessageRequest(BaseModel):
    message: str
    userid: str
    usertype: str
    
class ChatMessageResponse(BaseModel):
    response: str


@router.post("chatbot/message", response_model=ChatMessageResponse)
async def chat_endpoint(payload: ChatMessageRequest):
    """
    사용자 프롬프트를 받아 Agent를 실행하고 응답을 반환하는 API 엔드포인트
    """
    question = payload.message
    userid = payload.userid
    usertype = payload.usertype

    # `chat_service.py`를 호출하여 Agent 실행
    response = process_chat(question, userid, usertype)

    return {"response": response}












# ========================== 기존의 chat.py ==============================

# import sys
# import os
# from fastapi import APIRouter, HTTPException, Request
# from pydantic import BaseModel

# from app.services.chat_service import chatbot
# from app.db.chat_repository import save_chat

# # docker가 위치 인식을 못해서 이렇게 설정해줘야 한단다.
# # sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/../..")  # '/app'을 경로에 추가

# router = APIRouter()

# class ChatMessageRequest(BaseModel):
#     message: str

# class ChatMessageResponse(BaseModel):
#     response: str

# @router.post("", response_model=ChatMessageResponse)
# async def chat_message(request: Request, payload: ChatMessageRequest):
#     # 클라이언트의 IP 주소를 출력
#     client_host = request.client.host
#     message = payload.message
#     print("Received message from", client_host, ":", message)
    
#     response = chatbot(question=message)
#     print(response)
    
#     # 질문, 응답 DB에 넣기
#     await save_chat(message,response)
    
#     return ChatMessageResponse(response=response)