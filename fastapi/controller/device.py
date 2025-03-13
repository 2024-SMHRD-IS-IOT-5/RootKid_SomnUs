from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.nfc_service import nfc_service
from services.music_service import stream_music

router = APIRouter()

class NFCData(BaseModel):
    state: bool
    
@router.post("/nfc")
async def receive_nfc_data(data: NFCData):
    # 아두이노에서 nfc 데이터 수신
    if nfc_service.update_nfc_state(data.state):
        return {"message":"NFC 상태 업데이트 완료", "state": data.state}
    raise HTTPException(status_code=400, detail="NFC 상태 변경 없음") 

@router.get("/stream")
async def stream_endpoiont():
    return await stream_music()
