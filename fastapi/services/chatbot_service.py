# 챗봇 데이터 처리

# import httpx
# from config import CHATBOT_SERVER_URL

# async def process_chat_message(user_id: str, message: str):
#     """
#     Python 챗봇 서버로 메시지를 전송하고 응답을 받아오는 함수
#     """
#     async with httpx.AsyncClient() as client:
#         response = await client.post(
#             f"{CHATBOT_SERVER_URL}/chat",
#             json={"user_id": user_id, "message": message}
#         )
#         if response.status_code == 200:
#             return response.json().get("response", "챗봇 응답 없음")
#         else:
#             return f"오류 발생: {response.status_code}"
