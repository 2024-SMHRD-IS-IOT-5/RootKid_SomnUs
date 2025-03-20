
from fastapi import WebSocket
from utils.websocket_manager import websocket_manager

class WebSocketService:
    """WebSocket 비즈니스 로직을 관리하는 서비스 클래스"""

    async def connect(self, websocket: WebSocket):
        """클라이언트 연결"""
        await websocket_manager.connect(websocket)

    async def disconnect(self, websocket: WebSocket):
        """클라이언트 연결 종료"""
        await websocket_manager.disconnect(websocket)

    async def receive_message(self, websocket: WebSocket):
        """메시지 수신"""
        await websocket_manager.receive_message(websocket)

    # async def broadcast_message(self, message: str):
    #     """모든 클라이언트에게 메시지 전송"""
    #     await websocket_manager.broadcast(message)

# WebSocket 서비스 인스턴스 생성
websocket_service = WebSocketService()