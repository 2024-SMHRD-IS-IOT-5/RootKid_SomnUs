# app/chat/utils/async_helper.py
import asyncio
from functools import wraps
from typing import Any, Callable, Awaitable

class AsyncHelper:
    """비동기/동기 변환을 위한 유틸리티 클래스"""
    
    @staticmethod
    def sync_to_async(func: Callable) -> Callable:
        """
        동기 함수를 비동기 함수로 변환합니다.
        
        Args:
            func: 동기 함수
            
        Returns:
            Callable: 비동기 래퍼 함수
        """
        @wraps(func)
        async def wrapper(*args: Any, **kwargs: Any) -> Any:
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(None, lambda: func(*args, **kwargs))
        return wrapper
    
    @staticmethod
    def async_to_sync(func: Callable[..., Awaitable[Any]]) -> Callable:
        """
        비동기 함수를 동기 함수로 변환합니다.
        FastAPI와 같은 비동기 환경 외부에서 사용해야 합니다.
        
        Args:
            func: 비동기 함수
            
        Returns:
            Callable: 동기 래퍼 함수
        """
        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                return loop.run_until_complete(func(*args, **kwargs))
            finally:
                loop.close()
        return wrapper