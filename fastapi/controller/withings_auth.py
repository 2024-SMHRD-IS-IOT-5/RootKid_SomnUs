from fastapi import APIRouter, HTTPException
from services.withings_service import withings_service
from models.withings_model import WithingsAuthRequest

router = APIRouter()

@router.get("/withings/auth-url")
async def get_withings_auth_url():
    """Withings OAuth2 인증 URL 반환"""
    return {"auth_url": await withings_service.get_authorization_url()}

@router.post("/withings/auth")
async def authenticate_withings(request: WithingsAuthRequest):
    """Withings OAuth2 인증 처리"""
    try:
        token_response = await withings_service.exchange_code_for_token(request.code)
        return token_response  # access_token, refresh_token, user_id 반환
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
