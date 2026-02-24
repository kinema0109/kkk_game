from fastapi import APIRouter, Depends, HTTPException
import random
import time
from src.app.core.auth import get_current_user
from src.app.core.database import get_supabase
from src.app.core.config import settings
from src.app.core.i18n import get_translator, Translator
from src.app.api.websocket import manager as ws_manager
from src.app.core.logger import logger
from src.app.games.deception.manager import game_manager
from src.app.api.schemas import (
    GameCreateRequest, GameCreateResponse, GameJoinRequest, GameJoinResponse, 
    GameListResponse, LobbyGame, GameStatus, GameActionRequest,    ConfirmCrimeRequest, SolveRequest, DrawTilesRequest, GuessWitnessRequest, 
    SelectTileOptionRequest, ConfirmDraftRequest, GameUpdateMessage, MessageType
)

router = APIRouter(prefix="/game", tags=["Game"])

async def broadcast_game_state(game):
    state = game.to_game_state() if hasattr(game, 'to_game_state') else game
    
    await ws_manager.broadcast(
        GameUpdateMessage(
            type=MessageType.GAME_UPDATE,
            timestamp=time.time(),
            state=state
        ).model_dump(),
        game.room_id
    )

def generate_room_code():
    chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    return ''.join(random.choice(chars) for _ in range(6))

@router.get("/list", response_model=GameListResponse, summary="List public and joined game rooms")
async def list_games(current_user: dict = Depends(get_current_user)):
    """Fetches public games and games the user has joined."""
    supabase = get_supabase()
    
    # 1. Fetch public games in LOBBY status
    public_res = supabase.from_("games") \
        .select("id, room_code, name, host_id, game_type, players(count)") \
        .eq("status", GameStatus.LOBBY.value) \
        .eq("is_public", True) \
        .order("created_at", desc=True) \
        .execute()
    
    if public_res is None:
        logger.error("Supabase public games fetch returned None")
        raise HTTPException(status_code=500, detail="Database connection failure")

    # 2. Fetch games where the user is a player
    joined_res = supabase.from_("players") \
        .select("game_id, games(id, room_code, name, host_id, status, game_type, players(count))") \
        .eq("user_id", current_user["id"]) \
        .execute()
        
    if joined_res is None:
        logger.error("Supabase joined games fetch returned None")
        raise HTTPException(status_code=500, detail="Database connection failure")

    def format_game(g):
        player_info = g.get('players', [])
        p_count = player_info[0].get('count', 0) if player_info else 0
        return LobbyGame(
            id=g['id'],
            room_code=g['room_code'],
            name=g['name'],
            host_id=g['host_id'],
            player_count=p_count,
            game_type=g.get('game_type', 'deception')
        )

    public_games = [format_game(g) for g in public_res.data]
    
    my_games = []
    # Deduplicate: if a joined game is also in the public list, or if it's in progress
    seen_ids = set()
    for p in joined_res.data:
        game = p.get("games")
        if game and game["id"] not in seen_ids:
            my_games.append(format_game(game))
            seen_ids.add(game["id"])
        
    return GameListResponse(
        public_games=public_games,
        my_games=my_games
    )

@router.post("/create", response_model=GameCreateResponse, summary="Create a new game room")
async def create_game(req: GameCreateRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    """Generates a unique room code and creates a new game record."""
    supabase = get_supabase()
    
    room_code = generate_room_code()
    is_unique = False
    retries = 0
    
    while not is_unique and retries < 5:
        logger.debug(f"Checking room code uniqueness: {room_code}")
        existing = supabase.from_("games").select("id").eq("room_code", room_code).execute()
        if existing is None:
            logger.error(f"Supabase existing check returned None for code {room_code}")
            raise HTTPException(status_code=500, detail="Supabase connection failure")
        
        if not existing.data:
            is_unique = True
        else:
            room_code = generate_room_code()
            retries += 1
            
    if not is_unique:
        raise HTTPException(status_code=500, detail=t.t("game.code_gen_failed"))
        
    name = req.name or f"Room of {current_user['email'].split('@')[0] if current_user.get('email') else 'Player'}"
    
    logger.debug(f"Inserting new game: {room_code}, name: {name}")
    new_game = supabase.from_("games").insert({
        "room_code": room_code,
        "status": GameStatus.LOBBY.value,
        "host_id": current_user["id"],
        "name": name,
        "is_public": req.is_public
    }).execute()
    
    if new_game is None:
        logger.error("Supabase insert returned None")
        raise HTTPException(status_code=500, detail="Supabase insert failed (None response)")
        
    game_id = new_game.data[0]["id"]
    
    # Also add host as a player in the session
    supabase.table("players").insert({
        "game_id": game_id,
        "user_id": current_user["id"],
        "name": current_user.get("email", "Host").split("@")[0],
        "is_admin": True,
        "metadata": {"seat_index": 0}
    }).execute()
    
    return GameCreateResponse(game_id=game_id, room_code=room_code)

@router.post("/join", response_model=GameJoinResponse, summary="Join a game room")
async def join_game(req: GameJoinRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    """Validates room code and assigns player to the game."""
    supabase = get_supabase()
    
    room_code = req.room_code.upper()
    game_res = supabase.from_("games").select("id, status, host_id").eq("room_code", room_code).execute()
    if game_res is None:
        logger.error("Supabase game fetch returned None in join_game")
        raise HTTPException(status_code=500, detail="Database connection failure")
        
    if not game_res.data:
        raise HTTPException(status_code=404, detail=t.t("game.room_not_found"))
    
    game_data = game_res.data[0]
    game_id = game_data["id"]
    
    existing_player = supabase.from_("players").select("*").eq("game_id", game_id).eq("user_id", current_user["id"]).execute()
    if existing_player is None:
        logger.error("Supabase existing player check returned None in join_game")
        raise HTTPException(status_code=500, detail="Database connection failure")
    
    is_host = game_data["host_id"] == current_user["id"]
    is_admin = is_host or current_user.get("email") == settings.ADMIN_EMAIL
    
    update_res = supabase.from_("profiles").update({"display_name": req.name}).eq("id", current_user["id"]).execute()
    if update_res is None:
        logger.warning(f"Profile update returned None for user {current_user['id']}")
    
    player_id = None
    if existing_player.data:
        player = existing_player.data[0]
        player_id = player["id"]
        update_p_res = supabase.from_("players").update({
            "name": req.name,
            "is_admin": is_admin
        }).eq("id", player_id).execute()
        if update_p_res is None:
            logger.warning(f"Player update returned None for user {current_user['id']}")
    else:
        if game_data["status"] != GameStatus.LOBBY.value:
            raise HTTPException(status_code=403, detail=t.t("game.in_progress"))
            
        new_player = supabase.from_("players").insert({
            "game_id": game_id,
            "user_id": current_user["id"],
            "name": req.name,
            "is_admin": is_admin,
            "metadata": {"seat_index": random.randint(0, 1000)}
        }).execute()
        
        if new_player is None:
            logger.error("Supabase new player insert returned None in join_game")
            raise HTTPException(status_code=500, detail="Database connection failure")
            
        if not new_player.data:
            raise HTTPException(status_code=500, detail=t.t("game.join_failed"))
        player_id = new_player.data[0]["id"]
        
    # Sync with Game Manager
    await game_manager.handle_player_connect(game_id, current_user["id"], req.name, db_id=player_id)
    game_obj = await game_manager.get_game(game_id)
    if game_obj:
        await broadcast_game_state(game_obj)
        
    return GameJoinResponse(player_id=player_id, game_id=game_id, is_admin=is_admin)

# --- Generic Game Actions (REST Wrappers) ---

@router.post("/chat")
async def game_chat(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "chat", req.data)
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/start")
async def game_start(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "start_game", {})
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/reset")
async def game_reset(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "reset", {})
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/ready")
async def game_ready(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "ready", {})
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/confirm-draft")
async def confirm_draft(req: ConfirmDraftRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "confirm_draft", {
            "selected_means": req.selectedMeansIds,
            "selected_clues": req.selectedClueIds
        })
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/confirm-crime")
async def confirm_crime(req: ConfirmCrimeRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "confirm_crime", {
            "means_id": req.meansCardId,
            "clue_id": req.clueCardId
        })
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/solve")
async def game_solve(req: SolveRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "solve", {
            "suspect_id": req.suspectId,
            "means_id": req.meansCardId,
            "clue_id": req.clueCardId
        })
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/draw-tiles")
async def draw_tiles(req: DrawTilesRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "draw_tiles", {"mode": req.mode})
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/select-tile-option")
async def select_tile_option(req: SelectTileOptionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "select_tile_option", {
            "tile_id": req.gameTileId,
            "option_index": req.optionIndex
        })
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/guess-witness")
async def guess_witness(req: GuessWitnessRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "identify_witness", {
            "target_id": req.witnessPlayerId
        })
        return {"success": True}
    raise HTTPException(status_code=404, detail="Game not found")

@router.post("/kick")
async def game_kick(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        is_admin = current_user.get("role") == "admin" or current_user.get("email") == settings.ADMIN_EMAIL
        player = game.get_player(current_user["id"])
        if not (is_admin or (player and player.is_host)):
            raise HTTPException(status_code=403, detail=t.t("game.only_host_can_kick"))
            
        target_player_id = req.data.get("targetPlayerId")
        if target_player_id:
            await game.handle_event(current_user["id"], "leave", {"target_id": target_player_id})
            return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.target_not_found"))

@router.post("/close")
async def game_close(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        is_admin = current_user.get("role") == "admin" or current_user.get("email") == settings.ADMIN_EMAIL
        player = game.get_player(current_user["id"])
        if not (is_admin or (player and player.is_host)):
            raise HTTPException(status_code=403, detail=t.t("game.only_host_can_close"))
        
        supabase = get_supabase()
        supabase.table('games').delete().eq('id', req.gameId).execute()
        # Cleanup
        from src.app.games.deception.logic import state_manager
        await state_manager.delete_state(req.gameId)
        if req.gameId in game_manager.games:
            del game_manager.games[req.gameId]
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/leave")
async def game_leave(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        await game.handle_event(current_user["id"], "leave", {})
        return {"success": True}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.post("/sync")
async def game_sync_post(req: GameActionRequest, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(req.gameId)
    if game:
        return {"success": True, "game": game.to_game_state()}
    raise HTTPException(status_code=404, detail=t.t("game.not_found"))

@router.get("/sync/{game_id}")
async def game_sync_get(game_id: str, current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    game = await game_manager.get_game(game_id)
    if game:
        return {"success": True, "game": game.to_game_state()}
    raise HTTPException(status_code=404, detail="Game not found")
