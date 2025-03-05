from fastapi import WebSocket, WebSocketDisconnect
from typing import List
import json

class WebSocketManager:
    """WebSocket 연결 및 메시지 관리"""
    
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        """새로운 클라이언트 연결"""
        await websocket.accept()
        self.active_connections.append(websocket)
        print(f"클라이언트 연결됨: {websocket.client}")

    async def disconnect(self, websocket: WebSocket):
        """클라이언트 연결 해제"""
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            print(f"클라이언트 연결 종료: {websocket.client}")

    async def receive_message(self, websocket: WebSocket):
        """클라이언트로부터 메시지 수신"""
        try:
            while True:
                data = await websocket.receive_text()
                print(f"받은 메시지: {data}")
                await self.broadcast(f"서버 브로드캐스트: {data}")

        except WebSocketDisconnect:
            await self.disconnect(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        """특정 클라이언트에게 메시지 전송"""
        await websocket.send_text(message)

    async def broadcast(self, message: str):
        """모든 클라이언트에게 메시지 전송 (브로드캐스트)"""
        for connection in self.active_connections:
            try:
                await connection.send_text(json.dumps({"sender": "server", "text": message}))
            except Exception as e:
                print(f"메시지 전송 오류: {e}")

# WebSocket 매니저 인스턴스 생성
websocket_manager = WebSocketManager()
