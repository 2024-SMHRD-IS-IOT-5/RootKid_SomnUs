"""
chat_service.py




"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain.chat_models import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
from langchain.chains import LLMChain
import uvicorn

app = FastAPI(title="Chat Service")

# 요청 모델: 발화자 타입과 사용자의 메시지
class ChatRequest(BaseModel):
    speaker_type: str
    message: str

# 응답 모델: 챗봇이 생성한 답변
class ChatResponse(BaseModel):
    response: str

# OpenAI의 챗봇 모델 사용 (모델 이름은 필요에 따라 변경)
llm = ChatOpenAI(model_name="gpt-3.5-turbo")

# ChatPromptTemplate 정의
# 시스템 메시지에서 발화자 타입을 역할로 설정하여 챗봇이 그 관점에서 응답하도록 유도함
chat_prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are a chatbot serving as a {speaker_type}. Answer as if you were in that role."
    ),
    HumanMessagePromptTemplate.from_template("{message}")
])

# LLMChain 생성: 템플릿과 LLM을 연결
chain = LLMChain(prompt=chat_prompt, llm=llm)

# /chat 엔드포인트: ChatRequest를 받고, ChatResponse로 응답
@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(chat_request: ChatRequest):
    try:
        # 템플릿에 speaker_type과 message를 넣어 LLMChain 실행
        result = chain.run({
            "speaker_type": chat_request.speaker_type,
            "message": chat_request.message
        })
        return ChatResponse(response=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
