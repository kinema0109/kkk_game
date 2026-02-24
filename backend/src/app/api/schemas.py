from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any, Union
from enum import Enum

class MessageType(str, Enum):
    PLAYER_JOINED = "player_joined"
    PLAYER_LEFT = "player_left"
    GAME_START = "game_start"
    GAME_UPDATE = "game_update"
    PLAYER_ACTION = "player_action"
    CHAT = "chat"
    ERROR = "error"

class GameStatus(str, Enum):
    """Current status of the deception game session."""
    LOBBY = "LOBBY"
    SETUP = "SETUP"
    CARD_DRAFTING = "CARD_DRAFTING"
    CRIME_SELECTION = "CRIME_SELECTION"
    FORENSIC_SETUP = "FORENSIC_SETUP"
    INVESTIGATION = "INVESTIGATION"
    WITNESS_IDENTIFICATION = "WITNESS_IDENTIFICATION"
    GAME_OVER = "GAME_OVER"

class Role(str, Enum):
    """Player roles in Deception: Murder in Hong Kong."""
    FORENSIC_SCIENTIST = "FORENSIC_SCIENTIST"
    MURDERER = "MURDERER"
    INVESTIGATOR = "INVESTIGATOR"
    WITNESS = "WITNESS"
    ACCOMPLICE = "ACCOMPLICE"

class CardType(str, Enum):
    MEANS = "MEANS"
    CLUE = "CLUE"

class Player(BaseModel):
    id: str = Field(..., description="Unique identifier for the player", examples=["player_123"])
    name: str = Field(..., description="Display name of the player", examples=["Detective John"])
    is_host: bool = Field(False, description="Whether the player is the room host")
    is_ready: bool = Field(False, description="Player's readiness status")
    metadata: Dict[str, Any] = Field({}, description="Game-specific player data")

class GameState(BaseModel):
    room_id: str = Field(..., description="Unique identifier for the game room", examples=["ROOM_XYZ"])
    status: GameStatus = Field(GameStatus.LOBBY, description="Current phase of the game")
    players: List[Player] = Field([], description="List of players currently in the room")
    current_turn_owner: Optional[str] = Field(None, description="ID of the player whose turn it is")
    data: Dict[str, Any] = Field({}, description="Game-specific state data", examples=[{"phase": "Day 1", "evidence": []}])

# --- Lobby Management Schemas ---

class GameCreateRequest(BaseModel):
    name: Optional[str] = Field(None, description="Custom name for the room")
    is_public: bool = Field(True, description="Whether the room is visible in the public list")

class GameCreateResponse(BaseModel):
    game_id: str
    room_code: str

class GameJoinRequest(BaseModel):
    room_code: str = Field(..., description="6-character unique room code")
    name: str = Field(..., description="Nickname to use in game")

class GameJoinResponse(BaseModel):
    player_id: str
    game_id: str
    is_admin: bool

class LobbyGame(BaseModel):
    id: str
    room_code: str
    name: str
    host_id: str
    player_count: int
    game_type: str = "deception"

class GameListResponse(BaseModel):
    public_games: List[LobbyGame]
    my_games: List[LobbyGame]

class BaseMessage(BaseModel):
    type: MessageType
    timestamp: float = Field(default_factory=lambda: 0.0) # Placeholder, will be set on send

class PlayerJoinMessage(BaseMessage):
    type: MessageType = MessageType.PLAYER_JOINED
    player_id: str = Field(..., description="ID of the joining player")
    player_name: str = Field(..., description="Name of the joining player")

class PlayerLeftMessage(BaseMessage):
    type: MessageType = MessageType.PLAYER_LEFT
    player_id: str = Field(..., description="ID of the player who left")

class GameUpdateMessage(BaseMessage):
    type: MessageType = MessageType.GAME_UPDATE
    state: GameState = Field(..., description="Full updated game state")

class PlayerActionMessage(BaseMessage):
    type: MessageType = MessageType.PLAYER_ACTION
    player_id: str = Field(..., description="ID of the player performing the action")
    action: str = Field(..., description="The action being performed", examples=["select_card", "vote"])
    payload: Dict[str, Any] = Field({}, description="Additional action-specific data")

class ErrorMessage(BaseMessage):
    type: MessageType = MessageType.ERROR
    message: str = Field(..., description="Error message details", examples=["Room full", "Invalid action"])

class ChatMessage(BaseModel):
    player_id: Optional[str] = None
    player_name: str
    message: str
    is_system: bool = False
    timestamp: float

class GameActionRequest(BaseModel):
    gameId: str
    playerId: str
    data: Optional[Dict[str, Any]] = None

class ConfirmCrimeRequest(BaseModel):
    gameId: str
    playerId: str
    meansCardId: str
    clueCardId: str

class SolveRequest(BaseModel):
    gameId: str
    playerId: str
    suspectId: str
    meansCardId: str
    clueCardId: str

class DrawTilesRequest(BaseModel):
    gameId: str
    playerId: str
    mode: str # 'initial' | 'next_round'

class GuessWitnessRequest(BaseModel):
    gameId: str
    playerId: str
    witnessPlayerId: str

class SelectTileOptionRequest(BaseModel):
    gameId: str
    playerId: str
    gameTileId: str
    optionIndex: int

class ConfirmDraftRequest(BaseModel):
    gameId: str
    playerId: str
    selectedMeansIds: List[str]
    selectedClueIds: List[str]

# --- Library Management Schemas ---

class LibraryCardResponse(BaseModel):
    id: str
    game_type: str
    type: str
    content: str
    image_url: Optional[str] = None
    metadata: Dict[str, Any] = {}

class LibraryCardUpdateRequest(BaseModel):
    game_type: Optional[str] = None
    type: Optional[str] = None
    content: Optional[str] = None
    image_url: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

class LibraryCardCreateRequest(BaseModel):
    game_type: str
    type: str
    content: str
    image_url: Optional[str] = None
    metadata: Dict[str, Any] = {}

# --- Auth Flow Schemas ---

class RegisterRequest(BaseModel):
    email: str
    password: str
    display_name: str

class LoginRequest(BaseModel):
    email: str
    password: str

class AuthResponse(BaseModel):
    user_id: str
    email: str
    access_token: str
    refresh_token: str
    message: Optional[str] = None
