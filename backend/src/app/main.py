from fastapi import FastAPI, Depends, WebSocket, WebSocketDisconnect, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import json
import time
from jose import jwt

from src.app.core.config import settings
from src.app.core.logger import logger
from src.app.core.scheduler import start_scheduler, stop_scheduler
from src.app.core.database import init_supabase
from src.app.core.redis import init_redis, close_redis
from src.app.core.auth import get_current_user
from src.app.core.middleware import error_handling_middleware, rate_limit_middleware
from src.app.api.websocket import manager
from src.app.api.schemas import GameUpdateMessage, MessageType
from src.app.games.deception.manager import game_manager

from src.app.api.v1.auth import router as auth_router
from src.app.api.v1.game import router as game_router
from src.app.api.v1.admin import router as admin_router
from src.app.api.v1.cron import router as cron_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    logger.info("Backend starting up...")
    init_supabase()
    await init_redis()
    start_scheduler()
    yield
    # Shutdown logic
    logger.info("Backend shutting down...")
    await close_redis()
    stop_scheduler()

tags_metadata = [
    {"name": "General", "description": "Basic server health and root endpoints."},
    {"name": "Game", "description": "Game room and logic management."},
    {"name": "Realtime", "description": "WebSocket endpoints for live game updates."},
]

app = FastAPI(
    title="Deception Manager API",
    description="Professional backend for Deception adaptation.",
    version="1.0.0",
    openapi_tags=tags_metadata,
    lifespan=lifespan
)

# Middlewares
app.middleware("http")(error_handling_middleware)
app.middleware("http")(rate_limit_middleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth_router, prefix="/api/v1")
app.include_router(game_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1")
app.include_router(cron_router, prefix="/api/v1")

@app.get("/", tags=["General"])
async def root():
    return {"message": "Welcome to Manager Game API"}

@app.get("/health", tags=["General"])
async def health_check():
    return {"status": "healthy"}

@app.websocket("/ws/{room_id}/{client_id}/{player_name}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str, player_name: str, token: str = Query(...)):
    from src.app.core.auth import verify_supabase_jwt
    try:
        # Using shared verification logic that supports HS256 and ES256/JWKS
        user_info = verify_supabase_jwt(token)
        user_id = user_info.get("id")
        
        if user_id != client_id:
            logger.warning(f"WebSocket Auth mismatch: token sub {user_id} != client_id {client_id}")
            await websocket.close(code=4003)
            return
    except Exception as e:
        logger.error(f"WebSocket Auth Error: {e}")
        await websocket.close(code=4001)
        return

    await manager.connect(websocket, room_id, client_id)
    game = await game_manager.handle_player_connect(room_id, client_id, player_name)
    
    try:
        # Initial broadcast on connect
        await game.broadcast_state()

        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            event_type = message.get("type")
            event_data = message.get("data", {})
            
            # handle_event will process logic and broadcast the new state
            await game.handle_event(client_id, event_type, event_data)
    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id, client_id)
        # Ensure we trigger the leave logic for host exit closure
        await game.handle_event(client_id, "leave", {})
    except Exception as e:
        logger.error(f"WebSocket Error: {e}")
        manager.disconnect(websocket, room_id, client_id)
        # Note: Do NOT call handle_event(leave) here, it purges the room on logic errors.
        # Let the host stay "online" until intentional disconnect or timeout.
