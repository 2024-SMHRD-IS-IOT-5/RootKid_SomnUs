from pydantic import BaseModel

class WithingsAuthRequest(BaseModel):
    """Withings OAuth2 인증 요청 모델"""
    code: str

class WithingsTokenResponse(BaseModel):
    """Withings OAuth2 토큰 응답 모델"""
    access_token: str
    refresh_token: str
    user_id: str
