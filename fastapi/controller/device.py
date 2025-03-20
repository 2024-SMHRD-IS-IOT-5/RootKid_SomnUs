from fastapi import APIRouter, HTTPException, Depends, WebSocket, Query
from pydantic import BaseModel
from services.nfc_service import nfc_service
from services.music_service import stream_music
from services.websocket_service import websocket_service
from utils.auth import get_current_user
from models.auth_models import TokenData
import asyncio

router = APIRouter()

class NFCData(BaseModel):
    state: bool
    
@router.post("/nfc/receive")
async def receive_nfc_data(data: NFCData, current_user: TokenData = Depends(get_current_user)):
    # 아두이노에서 nfc 데이터 수신, NFC값이 1인경우 부모님에게 알람전송
    if not hasattr(current_user, "role") or current_user.role != "parent":
        return {"message":"사용자에게는 알람을 띄우지 않습니다", "state": data.state}
    
    if nfc_service.update_nfc_state(data.state):
        return {"message": "NFC update complete", "state": data.state}
    raise HTTPException(status_code=400, detail="NFC not changed") 

@router.websocket("/nfc")
async def nfc_websocket_endpoint(websocket: WebSocket):
    # 헤더에서 토큰 추출
    auth_header = websocket.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        await websocket.close(code=1008)
        return
    token = auth_header.split(" ")[1]

    try:
        current_user = get_current_user(token)
    except HTTPException as e:
        await websocket.close(code=1008)
        return

    # 부모 계정이 아닐 때 연결 종료
    if current_user.role != "parent":
        await websocket.close(code=1008)
        return

    await websocket_service.connect(websocket)

    # 초기 상태를 None으로 설정하여 첫 번째 실행 시에도 변화를 감지할 수 있도록 함
    last_state = None

    try:
        while True:
            current_state = nfc_service.get_current_state()

            # 상태 변화 감지
            if current_state != last_state:
                await websocket.send_json({"nfc_state": current_state})
                last_state = current_state  # 상태 업데이트

            await asyncio.sleep(1)
    except Exception as e:
        print(f"WebSocket 에러: {e}")
    finally:
        await websocket_service.disconnect(websocket)
        await websocket.close()

# @router.websocket("/nfc")
# async def nfc_websocket_endpoint(websocket: WebSocket):
#     # 헤더에서 토킁 추출
#     auth_header = websocket.headers.get("Authorization")
#     if not auth_header or not auth_header.startswith("Bearer "):
#         await websocket.close(code=1008)
#         return
#     token = auth_header.split(" ")[1]
    
#     try:
#         current_user = get_current_user(token)
#     except HTTPException as e:
#         WebSocket.close(code=1008)
#         return
    
#     # 부모 계정이 아닐 때 연결 종료
#     if current_user.role != "parent":
#         await websocket.close(code=1008)
#         return
    
#     await websocket_service.connect(websocket)
    
#     # 초기 상태 False
#     last_state = False
    
#     try:
#         while True:
#             current_state = nfc_service.get_current_state()
#             # state 가 false -> true 일 때만 전송
#             if current_state and not last_state:
#                 await websocket.send_json({"nfc_state":current_state})
#                 last_state = True
#             elif not current_state:
#                 last_state = False
                
#             await asyncio.sleep(1)
#     except Exception as e:
#         print(f"WebSocket 에러: {e}")
#     finally:
#         await websocket_service.disconnect(websocket)
#         await websocket.close()
            

@router.get("/stream")
async def device_control(
    title: str = Query(None, description="음악 제목 (음악 기능 사용 시 필수)", example="whale"),
    action: str = Query(None, description="음악 동작 (재생, 중지 등)", example="play"),
    state: bool = Query(None, description="NFC 상태 (True / False)")
):
    response = {}
    
    if title and action:
        response["music_response"] = await stream_music(title, action)
        
    if state is not None:  # NFC 값이 제공된 경우만 처리
        if nfc_service.update_nfc_state(state):
            response["nfc_response"] = {"message": "NFC 상태 업데이트 완료", "state": state}
        else:
            response["nfc_response"] = {"message": "NFC 상태 변경 없음"}    
            
    if response:
        return response

    # 잘못된 요청 방지
    raise HTTPException(status_code=400, detail="적어도 하나의 요청을 제공해야 합니다. (음악 제어 또는 NFC 상태 변경)")
#     return await stream_music(title,action)                                                                                                                                                                                                                                                   

# @router.get("/nfc_a")
# async def receive_nfc_data(data: NFCData):
#     # 아두이노에서 nfc 데이터 수신
#     if nfc_service.update_nfc_state(data.state):
#         return {"message":"NFC 상태 업데이트 완료", "state": data.state}
#     raise HTTPException(status_code=400, detail="NFC 상태 변경 없음") 