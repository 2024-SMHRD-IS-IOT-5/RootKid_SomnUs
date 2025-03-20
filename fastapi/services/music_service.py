import io
from fastapi import HTTPException
from starlette.responses import StreamingResponse, JSONResponse
from core.database import musics_collection


async def stream_music(title:str, action:str) -> StreamingResponse:
    """
    MongoDB의 playlist 컬렉션에서 title에 매창하는 곡을 찾아,
    파일 데이터를 MP3 스트리밍 형태로 반환합니다.
    """

    doc = await musics_collection.find_one({"title":title})
    if not doc:
        raise HTTPException(status_code=404, detail="song not found")
    
    print(title)
    print(action)
    mp3_data = doc.get("file_data")
    if not mp3_data:
        raise HTTPException(status_code=404, detail="no file data available")
    
    if action == "play":
        # MP3 데이터를 10번 반복 (간단한 반복; MP3 파일 구조에 따라 별도의 처리가 필요할 수 있음)
        repeated_data = bytes(mp3_data) * 10
        stream = io.BytesIO(repeated_data)
        return StreamingResponse(stream, media_type="audio/mpeg")
    elif action == "pause":
        # pause 일 경우, 재생 장치 정지 메시지 반환
        return JSONResponse(content={"message": "Playback paused"})
    else:
        raise HTTPException(status_code=400, detail="Invalid action")
    
    #전정우 여기 다녀감 #일시정지 구현 #action 받아 case분류 #성공적