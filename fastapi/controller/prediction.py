from fastapi import APIRouter, HTTPException, Query, Depends
from services.prediction_service import compute_sleep_score_stacking, compute_sleep_score_mlp
from utils.auth import get_current_user
from models.auth_models import TokenData

router = APIRouter()

@router.get("/predict/stacking")
async def get_sleep_prediction_stacking(
    current_user: TokenData = Depends(get_current_user),
    sleep_record_id: str = Query(None, description="수면 기록 ID")
):
    """ 수면 정보들을 토대로 sleep_score 예측 """
    try:
        result = await compute_sleep_score_stacking(current_user.user_id, sleep_record_id)
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"예측 처리 중 오류 발생: {e}")
    return result

@router.get("/predict/mlp")
async def get_sleep_prediction_mlp(
    current_user: TokenData = Depends(get_current_user),
    sleep_record_id: str = Query(None, description="수면 기록 ID")
):
    """ 수면 정보들을 토대로 sleep_score 예측 """
    try:
        result = await compute_sleep_score_mlp(current_user.user_id, sleep_record_id)
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"예측 처리 중 오류 발생: {e}")
    return result
