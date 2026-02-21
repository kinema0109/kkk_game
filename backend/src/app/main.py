from fastapi import FastAPI, Depends, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from src.app.core.config import settings
from src.app.core.logger import logger
from src.app.core.scheduler import start_scheduler, stop_scheduler
from src.app.core.database import init_supabase
from src.app.core.redis import init_redis, close_redis
from src.app.api.websocket import manager
from src.app.api.schemas import GameUpdateMessage, MessageType
from src.app.games.deception.manager import game_manager
from contextlib import asynccontextmanager
import json
import time

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
    {
        "name": "General",
        "description": "Basic server health and root endpoints.",
    },
    {
        "name": "Game",
        "description": "Game room and logic management.",
    },
    {
        "name": "Realtime",
        "description": "WebSocket endpoints for live game updates.",
    },
]

app = FastAPI(
    title="Deception Manager API",
    description="""
Professional backend for the 'Deception: Murder in Hong Kong' web adaptation.
Provides realtime state management, game logic orchestration, and Supabase integration.
""",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_tags=tags_metadata,
    lifespan=lifespan
)

# Set up CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", tags=["General"], summary="Root endpoint")
async def root():
    """Returns a welcome message."""
    return {"message": "Welcome to Manager Game API"}

@app.get("/health", tags=["General"], summary="Health check")
async def health_check():
    """Verifies that the server and core services are healthy."""
    return {"status": "healthy"}

@app.websocket("/ws/{room_id}/{client_id}/{player_name}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str, player_name: str):
    """
    Main WebSocket endpoint for game interaction.
    
    Handlers:
    - Connection/Reconnection of players.
    - Realtime stale state broadcast.
    - Event handling (actions, chat, etc.).
    - Disconnection cleanup.
    """
    await manager.connect(websocket, room_id)
    logger.info(f"Client {client_id} ({player_name}) connected to room {room_id}")
    
    # Handle player connection/reconnection
    game = await game_manager.handle_player_connect(room_id, client_id, player_name)
    
    try:
        # Initial state broadcast
        await manager.broadcast(
            GameUpdateMessage(
                type=MessageType.GAME_UPDATE,
                timestamp=time.time(),
                state=game
            ).model_dump(),
            room_id
        )
        
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            event_type = message.get("type")
            event_data = message.get("data", {})
            
            logger.debug(f"Event received from {client_id} in {room_id}: {event_type}")
            await game.handle_event(client_id, event_type, event_data)
            
            # Broadcast updated state
            await manager.broadcast(
                GameUpdateMessage(
                    type=MessageType.GAME_UPDATE,
                    timestamp=time.time(),
                    state=game
                ).model_dump(),
                room_id
            )
    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id)
        logger.info(f"Client {client_id} disconnected from room {room_id}")
    except Exception as e:
        logger.error(f"WebSocket Error for {client_id} in {room_id}: {e}")
        manager.disconnect(websocket, room_id)
