import json
from typing import Optional, Type, TypeVar
from pydantic import BaseModel
from .redis import get_redis
from .logger import logger

T = TypeVar("T", bound=BaseModel)

class RedisStateManager:
    def __init__(self, prefix: str = "game"):
        self.prefix = prefix

    async def set_state(self, key: str, state: BaseModel, ttl: int = 3600):
        client = get_redis()
        if not client:
            return
        
        try:
            full_key = f"{self.prefix}:{key}"
            # Use model_dump_json for Pydantic v2
            await client.set(full_key, state.model_dump_json(), ex=ttl)
        except Exception as e:
            logger.error(f"Redis set_state error: {e}")

    async def get_state(self, key: str, model: Type[T]) -> Optional[T]:
        client = get_redis()
        if not client:
            return None
        
        try:
            full_key = f"{self.prefix}:{key}"
            data = await client.get(full_key)
            if data:
                return model.model_validate_json(data)
        except Exception as e:
            logger.error(f"Redis get_state error: {e}")
        return None

    async def delete_state(self, key: str):
        client = get_redis()
        if not client:
            return
        
        try:
            full_key = f"{self.prefix}:{key}"
            await client.delete(full_key)
        except Exception as e:
            logger.error(f"Redis delete_state error: {e}")
