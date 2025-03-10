import httpx
import json
import urllib.parse
from core.config import WITHINGS_CLIENT_ID, WITHINGS_CLIENT_SECRET, WITHINGS_REDIRECT_URI, WITHINGS_API_URL
from core.database import sleep_collection, processing_sleep_collection
from models.withings_model import WithingsSleepData

class WithingsService:
    """Withings API 연동 및 데이터 처리 서비스"""

    async def get_authorization_url(self) -> str:
        """사용자를 Withings 로그인 페이지로 리디렉션하여 승인 요청"""
        state = "random_state_string"  # 보안 강화를 위해 랜덤 값 설정 가능
        scope = "user.info,user.metrics,user.activity"
        
        payload = {
            "response_type": "code",
            "client_id": WITHINGS_CLIENT_ID,
            "state": state,
            "scope": scope,
            "redirect_uri": WITHINGS_REDIRECT_URI
        }
        
        query_string = urllib.parse.urlencode(payload)
        auth_url = f"https://account.withings.com/oauth2_user/authorize2?{query_string}"
        
        return auth_url

    async def exchange_code_for_token(self, code: str) -> dict:
        """Withings OAuth2 인증 코드로 액세스 토큰 요청"""
        params = {
            "action": "requesttoken",
            "grant_type": "authorization_code",
            "client_id": WITHINGS_CLIENT_ID,
            "client_secret": WITHINGS_CLIENT_SECRET,
            "code": code,
            "redirect_uri": WITHINGS_REDIRECT_URI
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{WITHINGS_API_URL}/v2/oauth2", data=params)
            response_data = response.json()
        
        if "body" in response_data and "access_token" in response_data["body"]:
            return {
                "access_token": response_data["body"]["access_token"],
                "refresh_token": response_data["body"]["refresh_token"],
                "user_id": response_data["body"]["userid"]
            }
        else:
            raise Exception("Withings OAuth2 인증 실패")

    async def refresh_token(self, refresh_token: str) -> dict:
        """Withings OAuth2 액세스 토큰 갱신"""
        params = {
            "action": "requesttoken",
            "grant_type": "refresh_token",
            "client_id": WITHINGS_CLIENT_ID,
            "client_secret": WITHINGS_CLIENT_SECRET,
            "refresh_token": refresh_token
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(f"{WITHINGS_API_URL}/v2/oauth2", data=params)
            response_data = response.json()

        if "body" in response_data and "access_token" in response_data["body"]:
            return {
                "access_token": response_data["body"]["access_token"],
                "refresh_token": response_data["body"]["refresh_token"]
            }
        else:
            raise Exception("Withings 토큰 갱신 실패")

    async def fetch_sleep_data(self, access_token: str) -> dict:
        """Withings에서 수면 데이터 가져오기"""
        headers = {"Authorization": f"Bearer {access_token}"}
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{WITHINGS_API_URL}/v2/sleep", headers=headers)
            return response.json()

withings_service = WithingsService()