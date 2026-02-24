from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from abc import ABC, abstractmethod
import time

class BasePlayer(BaseModel):
    id: str
    db_id: Optional[str] = None
    name: str
    is_host: bool = False
    is_ready: bool = False
    is_online: bool = True
    last_seen: float = Field(default_factory=time.time)
    metadata: Dict[str, Any] = {}

class BaseRoom(BaseModel, ABC):
    room_id: str
    room_code: str
    host_id: Optional[str] = None
    players: List[BasePlayer] = []
    status: str = "LOBBY"
    created_at: float = Field(default_factory=time.time)
    metadata: Dict[str, Any] = {}
    
    @abstractmethod
    async def handle_event(self, player_id: str, event_type: str, data: Dict[str, Any]):
        """Handle incoming WebSocket events specific to the game."""
        pass

    def add_player(self, player: BasePlayer):
        existing = self.get_player(player.id)
        if existing:
            existing.is_online = True
            existing.last_seen = time.time()
        else:
            self.players.append(player)

    def remove_player(self, player_id: str):
        player = self.get_player(player_id)
        if player:
            player.is_online = False
            player.last_seen = time.time()

    def get_player(self, player_id: str) -> Optional[BasePlayer]:
        for p in self.players:
            if p.id == player_id:
                return p
        return None

    def serialize_state(self) -> Dict[str, Any]:
        """Convert the room and game state to a serializable dictionary."""
        return self.model_dump()
