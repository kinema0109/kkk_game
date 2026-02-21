from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any, Union
from enum import Enum

class MessageType(str, Enum):
    PLAYER_JOINED = "player_joined"
    PLAYER_LEFT = "player_left"
    GAME_START = "game_start"
    GAME_UPDATE = "game_update"
    PLAYER_ACTION = "player_action"
    ERROR = "error"

class GameStatus(str, Enum):
    LOBBY = "lobby"
    IN_PROGRESS = "in_progress"
    FINISHED = "finished"

class Player(BaseModel):
    id: str
    name: str
    is_host: bool = False
    is_ready: bool = False

class GameState(BaseModel):
    room_id: str
    status: GameStatus = GameStatus.LOBBY
    players: List[Player] = []
    current_turn_owner: Optional[str] = None
    data: Dict[str, Any] = {}  # Flexible data for game specific state

class BaseMessage(BaseModel):
    type: MessageType
    timestamp: float = Field(default_factory=lambda: 0.0) # Placeholder, will be set on send

class PlayerJoinMessage(BaseMessage):
    type: MessageType = MessageType.PLAYER_JOINED
    player_id: str
    player_name: str

class PlayerLeftMessage(BaseMessage):
    type: MessageType = MessageType.PLAYER_LEFT
    player_id: str

class GameUpdateMessage(BaseMessage):
    type: MessageType = MessageType.GAME_UPDATE
    state: GameState

class PlayerActionMessage(BaseMessage):
    type: MessageType = MessageType.PLAYER_ACTION
    player_id: str
    action: str
    payload: Dict[str, Any] = {}

class ErrorMessage(BaseMessage):
    type: MessageType = MessageType.ERROR
    message: str
