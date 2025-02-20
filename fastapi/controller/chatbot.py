# 챗봇과 통신 , fastAPI 웹소켓 엔드포인트

# from fastapi import WebSocket, WebSocketDisconnect, APIRouter
# from services.chatbot_service import process_chat_message

# router = APIRouter(prefix="/chatbot", tags=["Chatbot"])

# # 현재 활성화된 웹소켓 연결 저장
# active_connections = {}

# @router.websocket("/ws/{user_id}")
# async def chatbot_websocket(websocket: WebSocket, user_id: str):
#     """ 웹소켓을 이용해 챗봇과 실시간으로 대화 """
#     await websocket.accept()
#     active_connections[user_id] = websocket

#     try:
#         while True:
#             message = await websocket.receive_text()  # 클라이언트 메시지 수신
#             response = await process_chat_message(user_id, message)  # 챗봇 응답 처리
#             await websocket.send_text(response)  # 클라이언트에게 응답 전송
#     except WebSocketDisconnect:
#         del active_connections[user_id]  # 연결 종료 시 리스트에서 제거
