from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List
import json
from langchain.chat_models import ChatOpenAI

app = FastAPI()
chatbot = ChatOpenAI(model_name="gpt-4", temperature=0.7)

class WebSocketManager:
    """WebSocket 연결 관리"""
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        """클라이언트 연결"""
        await websocket.accept()
        self.active_connections.append(websocket)

    async def disconnect(self, websocket: WebSocket):
        """클라이언트 연결 해제"""
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        """모든 연결된 클라이언트에게 메시지 전송"""
        for conn in self.active_connections:
            await conn.send_text(json.dumps({"report": message}))

ws_manager = WebSocketManager()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """FastAPI WebSocket 엔드포인트"""
    await ws_manager.connect(websocket)

    try:
        while True:
            data = await websocket.receive_text()
            request = json.loads(data)

            if request.get("type") == "daily_report":
                response = "📝 오늘의 수면 보고서: 수면 시간 7시간, 수면 점수 85점"
                await ws_manager.broadcast(response)
            else:
                response = chatbot.predict(request["message"])
                await websocket.send_text(json.dumps({"response": response}))

    except WebSocketDisconnect:
        await ws_manager.disconnect(websocket)