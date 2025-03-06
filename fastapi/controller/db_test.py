from fastapi import APIRouter
from core.database import client, users_collection
from bson import ObjectId # ObjectID 변환을 위해 추가
from core.security import hash_password, verify_password, create_access_token

router = APIRouter()

@router.get("/test-db")
async def test_db_connection():
    #MongoDB 연결 테스트"""
    try:
        # ✅ MongoDB의 모든 데이터베이스 목록 가져오기
        db_list = await client.list_database_names()
        return {"message": "MongoDB 연결 성공!", "databases": db_list}
    except Exception as e:
        return {"error": str(e)}

@router.post("/test-insert")
async def test_insert():
    #MongoDB에 테스트 데이터 삽입"""
    try:
        existing_user = await users_collection.find_one({"id": "test22"})
        if existing_user:
            return {"error": "이미 존재하는 아이디입니다."}
        
        password = "1234"
        hashed_password = hash_password(password)
        new_user = {"id":"test123", "password": hashed_password, "username":"smhrd", "userage": 20100101, "userweight":40}
        result = await users_collection.insert_one(new_user)
        return {"message": "데이터 삽입 성공!", "inserted_id": str(result.inserted_id)}
    
    except Exception as e:
        return {"error": str(e)}

@router.get("/test-find")
async def test_find():
    #MongoDB에서 데이터 조회"""
    try:
        data = await users_collection.find_one({"id": "smhrd"})
         
        if data:
            # '_id_를 문자열로 변환하여 반환
            data["_id"] = str(data["_id"])
            return {"message": "데이터 조회 성공!", "data": data}
        else:
            return {"message": "데이터 없음"}
        
    except Exception as e:
        return {"error": str(e)}