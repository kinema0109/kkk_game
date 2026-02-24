from fastapi import APIRouter, Depends, HTTPException
from src.app.core.auth import admin_only
from src.app.core.database import get_supabase
from src.app.core.config import settings
from src.app.core.i18n import get_translator, Translator
from src.app.api.schemas import LibraryCardCreateRequest, LibraryCardUpdateRequest, LibraryCardResponse
from typing import Optional

# Apply admin_only to all routes in this router
router = APIRouter(prefix="/admin", tags=["Admin"], dependencies=[Depends(admin_only)])

@router.get("/config", summary="Get admin configuration")
async def get_config(t: Translator = Depends(get_translator)):
    """Returns admin-specific configuration."""
    return {"adminEmail": settings.ADMIN_EMAIL, "message": t.t("admin.config_retrieved")}

@router.get("/tiles", summary="List all library tiles")
async def list_tiles():
    supabase = get_supabase()
    res = supabase.table("library_tiles").select("*").execute()
    return res.data if res else []

@router.get("/cards", summary="List and filter library cards")
async def list_cards(game_type: Optional[str] = None, card_type: Optional[str] = None):
    supabase = get_supabase()
    query = supabase.table("library_cards").select("*")
    if game_type:
        query = query.eq("game_type", game_type)
    if card_type:
        query = query.eq("type", card_type)
    
    res = query.order("content").execute()
    return res.data if res else []

@router.post("/cards", summary="Create a new library card")
async def create_card(req: LibraryCardCreateRequest):
    supabase = get_supabase()
    res = supabase.table("library_cards").insert(req.model_dump()).execute()
    if not res.data:
        raise HTTPException(status_code=500, detail="Failed to create card")
    return res.data[0]

@router.patch("/cards/{card_id}", summary="Update a library card")
async def update_card(card_id: str, req: LibraryCardUpdateRequest):
    supabase = get_supabase()
    res = supabase.table("library_cards").update(req.model_dump(exclude_unset=True)).eq("id", card_id).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Card not found or update failed")
    return res.data[0]

@router.delete("/cards/{card_id}", summary="Delete a library card")
async def delete_card(card_id: str):
    supabase = get_supabase()
    res = supabase.table("library_cards").delete().eq("id", card_id).execute()
    return {"success": True}

@router.get("/users", summary="List all registered profiles")
async def list_users():
    supabase = get_supabase()
    res = supabase.table("profiles").select("*").order("created_at", desc=True).execute()
    return res.data if res else []

@router.get("/rooms", summary="List all game rooms")
async def list_rooms():
    supabase = get_supabase()
    res = supabase.table("games").select("*, players(count)").order("created_at", desc=True).execute()
    return res.data if res else []

@router.delete("/storage/delete", summary="Cleanup storage")
async def delete_storage():
    # Implementation placeholder
    return {"success": True}
