from app.db.database import db

async def weekly_data_test():
    print("find 시작!")
    
    try:
        db_name = db.sleep
        print("DB에는 연결 성공함. 현재 DB: ",db_name)
    except Exception as e:
        print("DB에 연결 안됨; 에러: ", e)
        return
        
    collection_name = "processing_sleep"
    collections = await db.list_collection_names()
    if collection_name not in collections:
        print("컬렉션 설정이 잘못됨")
        return
    

    result = await db.sleep.find({"week_number":"2025-02-W4"}).to_list(length=None)
    return result
    