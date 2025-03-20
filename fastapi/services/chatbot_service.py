# 챗봇 데이터 처리
import httpx
from core.config import CHATBOT_SERVER_URL

class ChatbotService:
    """FastAPI 서버와 LangChain 챗봇 서버 간 HTTP 통신 관리"""
    
    async def send_message(self, message:str) -> str:
        """챗봇 서버에 메시지 전송 후 응답 수신"""
        
        url = f"{CHATBOT_SERVER_URL}/chatbot/message"
        print(f"🚀 FastAPI → 챗봇 서버 메시지 전송: {message}")
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(url, json={"message": message})
                response.raise_for_status() # HTTP 요청 오류 시 예외 발생
                chatbot_response = response.json().get("response", "챗봇 응답 오류 발생")
                print(f"✅ 챗봇 서버 응답: {chatbot_response}")  # ✅ 로그 추가
                return chatbot_response
        
        except httpx.HTTPStatusError as e:
            return {"error": f"HTTP 오류 발생: {e.response.status_code}"}
                
        except Exception as e:
            return {"error": f"챗봇 서버 요청 오류: {e}"}
        
    async def send_report(self, report_type:str) -> str:
        """챗봇 서버에 수면 데이터 요청 후 응답 수신"""
        url = f"{CHATBOT_SERVER_URL}/chatbot/{report_type}-report"
        print(f"📊 FastAPI → 챗봇 서버 {report_type} 보고서 요청")
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.get(url)
                response.raise_for_status()
                return response.json.get("report", "보고서 생성 오류")
        
        except httpx.HTTPStatusError as e:
            return {"error": f"HTTP 오류 발생: {e.response.status_code}"}
                
        except Exception as e:
            return {"error": f"챗봇 서버 요청 오류: {e}"}
                

chatbot_service = ChatbotService()