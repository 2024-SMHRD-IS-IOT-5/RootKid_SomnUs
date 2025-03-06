from fastapi import APIRouter, WebSocket
from services.websocket_service import websocket_service

router = APIRouter()

@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket_service.connect(websocket)
    await websocket_service.receive_message(websocket)