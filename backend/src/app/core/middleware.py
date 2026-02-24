from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
from src.app.core.logger import logger
import time

async def error_handling_middleware(request: Request, call_next):
    try:
        return await call_next(request)
    except HTTPException as exc:
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": exc.detail, "code": exc.status_code}
        )
    except Exception as exc:
        import traceback
        logger.error(f"Unhandled error: {exc}\n{traceback.format_exc()}")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"error": "Internal Server Error", "code": 500}
        )

# Simple Rate Limiting (Memory based for now, could use Redis)
rate_limit_store = {}

async def rate_limit_middleware(request: Request, call_next):
    if request.url.path.startswith("/api"):
        client_ip = request.client.host
        now = time.time()
        
        if client_ip not in rate_limit_store:
            rate_limit_store[client_ip] = []
        
        # Keep only requests from the last minute
        rate_limit_store[client_ip] = [t for t in rate_limit_store[client_ip] if now - t < 60]
        
        if len(rate_limit_store[client_ip]) > 100: # 100 requests per minute
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={"error": "Rate limit exceeded", "code": 429}
            )
        
        rate_limit_store[client_ip].append(now)
        
    return await call_next(request)
