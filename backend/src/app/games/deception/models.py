from pydantic import BaseModel
from typing import List, Optional
from uuid import UUID

class LibraryCard(BaseModel):
    id: UUID
    type: str  # 'MEANS' or 'CLUE'
    content: str
    image_url: Optional[str] = None

class LibraryTile(BaseModel):
    id: UUID
    name: str
    type: str
    options: List[str]

class GameBase(BaseModel):
    id: UUID
    room_code: str
    status: str
    round: int = 0

class DeceptionGameDetail(GameBase):
    murderer_id: Optional[UUID] = None
    means_id: Optional[UUID] = None
    clue_id: Optional[UUID] = None
    host_id: Optional[UUID] = None
