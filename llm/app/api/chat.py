from pydantic import BaseModel
from fastapi import APIRouter, HTTPException

from app.services.chat_service import chat_with_user
from app.services.chat_process import chat_to_template

chat_router = APIRouter()

# 요청 모델 정의
class ChatRequest(BaseModel):
    # id: str
    message: str

# 응답 모델 정의
class ChatResponse(BaseModel):
    response: str


id = "smhrd"

@chat_router.post("", response_model=ChatResponse)
async def handle_chat_message(request: ChatRequest):
    message = request.message
    try:
        print("사용자의 채팅: ",request.message)
        # if message == "어제 내 수면 점수 몇점이었어?":
        #     return {"response": "어제 수면 점수는 75점이었어요!"}
        # elif message == "나 잠을 잘 못 잔것 같은데 어떤 문제가 있었을까?":
        #     return {"response": "어제는 두 번이나 깨어나서 수면의 연속성이 약간 떨어졌어요. 호흡 곤란 횟수도 높아서 수면 무호흡증이 의심돼요."}
        # elif message == "오늘은 어떻게 해보면 좋을까?":
        #     return {"response": "수면을 개선하기 위해 호흡 운동이나 스트레칭으로 호흡 곤란을 줄이고, 자기 전 주변 환경을 조용하고 어둡게 유지해보세요."}        
        response = chat_with_user(request.message)
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))