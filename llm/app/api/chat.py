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

id, prompt가 없으면 에러 반환.

메시지, 유저 아이디, 유저 구분을 chat_service에 전달하여 처리.

Agent실행 결과를 return.

"""
from fastapi import APIRouter, HTTPException
from app.services.chat.chat_service import ChatService
from pydantic import BaseModel
from typing import Dict, Any, Union

router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    id: str
    # usertype: str
    
class ChatResponse(BaseModel):
    response: Union[str, Dict] 
    


@router.post("/chatbot/message", response_model=ChatResponse)
async def chat_endpoint(payload: ChatRequest):
    """
    사용자 프롬프트를 받아 Agent를 실행하고 응답을 반환하는 API 엔드포인트
    """
    message = payload.message
    # userid = payload.userid
    id = payload.id
    # usertype = payload.usertype
    usertype = "학생"
    print("userid: ",id,"\n메시지: ",message)
    
    chat_service = ChatService()
    

    # `chat_service.py`를 호출하여 Agent 실행
    result = await chat_service.process_message(id, message)

    return {"response": result["response"]}
