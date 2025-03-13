import io
from fastapi import HTTPException
from starlette.responses import StreamingResponse
from core.database import db
from bson.binary import Binary

async def stream_music():
    """
    MongoDB의 playlist 컬렉션에서 title에 매창하는 곡을 찾아,
    파일 데이터를 MP3 스트리밍 형태로 반환합니다.
    """
    
    playlist_collection = db["playlist"]
    doc = await playlist_collection.find_one({"title":"rain"})
    if not doc:
        raise HTTPException(status_code=404, detail="song not found")
    
    mp3_data = doc.get("file_data")
    if not mp3_data:
        raise HTTPException(status_code=404, detail="no file data available")
    
    stream = io.BytesIO(bytes(mp3_data))
    return StreamingResponse(stream, media_type="audio/mpeg")
    