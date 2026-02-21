import redis.asyncio as redis
from .config import settings
from .logger import logger

redis_client: redis.Redis = None

async def init_redis():
    global redis_client
    try:
        redis_client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=0,
            password=settings.REDIS_PASSWORD,
            decode_responses=True
        )
        # Test connection
        await redis_client.ping()
        logger.info(f"Connected to Redis at {settings.REDIS_HOST}:{settings.REDIS_PORT}")
    except Exception as e:
        logger.error(f"Failed to connect to Redis: {e}")
        redis_client = None

async def close_redis():
    if redis_client:
        await redis_client.close()
        logger.info("Redis connection closed.")

def get_redis() -> redis.Redis:
    return redis_client
