from fastapi import WebSocket, WebSocketDisconnect
from typing import List
import json

class WebSocketService:
    def __init__(self):
        self.connected_clients: List[WebSocket] = []
        
    async def connect(self, websocket: WebSocket):
        # 클라이언트 Websocket 연결
        await websocket.accept()
        self.connected_clients.append(websocket)
        print(f"Clinet connected : {websocket.client}")
        
    async def disconnect(self, websocket: WebSocket):
        # 클라이언트 연결 종류
        self.connected_clients.remove(websocket)
        print("Client disconnected")
        
    async def receive_message(self, websocket: WebSocket):
        # 메시지 수신
        try:
            while True:
                data = await websocket.receive_text()
                print(f"Received: {data}")
                # await self.broadcast_message(f"Server: {data}")
        except WebSocketDisconnect:
            await self.disconnect(websocket)
        
    async def broadcast_message(self, message:str):
        # 메시지 전송
        for client in self.connected_clients:
            try:
                await client.send_text(json.dumps({"sender":"server", "text":message }))
            except Exception as e:
                print(f"Error sending message : {e}")
                

websocket_service = WebSocketService()
                                        