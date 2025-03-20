import pickle
from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from core.database import sleep_collection
import torch
import torch.nn as nn
import pandas as pd 
from sklearn.preprocessing import StandardScaler
from core.database import sleep_collection
from bson import ObjectId
import numpy as np


class MLPRegressor(nn.Module):
    def __init__(self):
        super(MLPRegressor, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(8, 64),   # 입력: 8개 피처, 출력: 64개 뉴런
            nn.ReLU(),
            nn.Linear(64, 32),  # 은닉층: 64 -> 32
            nn.ReLU(),
            nn.Linear(32, 1)    # 최종 출력: 1개 값 (예측)
        )
    
    def forward(self, x):
        return self.model(x)
    
try:
    # MLPRegressor 클래스의 인스턴스 생성
    mlp_model = MLPRegressor()
    # 저장된 state_dict를 로드합니다.
    #mlp_model.load_state_dict(torch.load("model/mlp_regressor.pth", map_location=torch.device("cpu")))
    mlp_model.load_state_dict(torch.load("model/mlp_regressor.pth"))
    mlp_model.eval()  # 평가 모드 전환
    print("✅ MLPRegressor 모델이 성공적으로 로드되었습니다!")
    
    # # Stacking Ensemble 모델 로드
    # with open("model/stacking_model.pkl", "rb") as f:
    #     stacking_model = pickle.load(f)

except Exception as e:
    raise RuntimeError(f"모델 로드 실패: {e}")


async def compute_sleep_score_mlp(user_id:str, sleep_record_id: str=None) -> dict:
    """mlp모델로 sleep_score 예측"""
    query = {"id": user_id}
    if sleep_record_id:
        try:
            query["_id"] = ObjectId(sleep_record_id)
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"_id 변환 오류: {e}")
    
    sleep_data = await sleep_collection.find_one(query, sort=[("date",-1)])
    
    sleep_duration = sleep_data["endDt"] - sleep_data["startDt"]
    lightsleepduration = sleep_data["lightsleep_duration"]
    deepsleepduration  = sleep_data["deepsleep_duration"]
    remsleepduration  = sleep_data["remsleep_duration"]
    
    if not sleep_data:
        raise HTTPException(status_code=404, detail="수면 데이터가 존재하지 않습니다")
    try:
        features = [
        int(sleep_duration),
        float(lightsleepduration),
        float(deepsleepduration),
        float(remsleepduration),
        float(sleep_data["hr_max"]),
        float(sleep_data["hr_average"]),
        int(sleep_data["rr_min"]),
        int(sleep_data["rr_average"])
    ]
    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"필수 필드 누락: {e}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"피처 값 처리 오류: {e}")

    try:
        # 입력 데이터를 2차원 텐서로 구성
        # NumPy 배열로 변환하고 2차원 배열로 reshape
        features_np = np.array(features).reshape(1, -1)

        # 데이터 정규화
        scaler = StandardScaler()
        X_normalized = scaler.fit_transform(features_np)

        X = torch.tensor(X_normalized, dtype=torch.float32)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Tensor 생성 오류: {e}")
    
    try:
        with torch.no_grad():
            prediction = mlp_model(X)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"예측 처리 중 오류 발생: {e}")
    
    try:
        # 예측 결과가 tensor 라면 스칼라 값 추출
        sleep_score = prediction.item()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"예측 결과 처리 오류: {e}")
    
    
    return {"sleep_score": sleep_score}

# async def compute_sleep_score_stacking(user_id:str, sleep_record_id:str =None)->dict:
#     """Stcaking Ensemble모델로 sleep_score 예측"""
#     query = {"id": user_id}
#     if sleep_record_id:
#         query["_id"] = sleep_record_id
        
#     sleep_data = await sleep_collection.find_one(query, sort=[("_id"),-1])
    
#     if not sleep_data:
#         raise HTTPException(status_code=404, detail="수면 데이터가 존재하지 않습니다")
#     try:
#         # 모델에 사용한 입력 feature
#         features = [
            # float(sleep_data["sleep_duration"]),
            # float(sleep_data["lightsleepduration"]),
            # float(sleep_data["deepsleepduration"]),
            # float(sleep_data["remsleepduration"]),
            # float(sleep_data["hr_max"]),
            # float(sleep_data["hr_average"]),
            # float(sleep_data["rr_min"]),
            # float(sleep_data["rr_average"])

#         ]
#     except KeyError as e:
#         raise HTTPException(status_code=400, detail=f"필수 필드 누락:{e}")
#     except Exception as e:
#         raise HTTPException(status_code=400, detail=f"피쳐 값 처리 오류: {e}")

#     X = [features]    
    
#     try:
#         prediction = stacking_model.predict(X)
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"예측 처리 중 오류 발생: {e}")

#     # 예측 결과가 배열로 반환
#     sleep_score = prediction[0] if prediction else None    
#     return {"sleep_score": sleep_score}

