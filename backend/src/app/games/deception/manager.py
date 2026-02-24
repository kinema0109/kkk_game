from typing import List, Dict, Any, Optional
from .logic import DeceptionGame, DeceptionPlayer

class GameManager:
    def __init__(self):
        self.games: Dict[str, DeceptionGame] = {}

    def create_game(self, room_id: str, room_code: str, host_id: Optional[str] = None) -> DeceptionGame:
        game = DeceptionGame(room_id=room_id, room_code=room_code, host_id=host_id)
        self.games[room_id] = game
        return game

    async def get_game(self, room_id: str) -> Optional[DeceptionGame]:
        # Check memory first
        if room_id in self.games:
            return self.games[room_id]
        
        # Check Redis
        from .logic import state_manager
        game = await state_manager.get_state(room_id, DeceptionGame)
        if game:
            self.games[room_id] = game
            return game
        return None

    async def handle_player_connect(self, room_id: str, player_id: str, player_name: str, db_id: Optional[str] = None) -> DeceptionGame:
        game = await self.get_game(room_id)
        if not game:
            # Fetch from Supabase to recover room info
            from src.app.core.database import get_supabase
            supabase = get_supabase()
            res = supabase.table("games").select("room_code, host_id").eq("id", room_id).execute()
            
            if res and res.data:
                g_data = res.data[0]
                game = self.create_game(room_id, g_data["room_code"], host_id=g_data["host_id"])
            else:
                game = self.create_game(room_id, room_id)
            
        if not db_id:
            # Try to fetch from database if missing (recovery scenario)
            from src.app.core.database import get_supabase
            supabase = get_supabase()
            p_res = supabase.table("players").select("id").eq("game_id", room_id).eq("user_id", player_id).execute()
            if p_res and p_res.data:
                db_id = p_res.data[0]["id"]

        player = game.get_player(player_id)
        if player:
            player.is_online = True
            if db_id:
                player.db_id = db_id
        else:
            player = DeceptionPlayer(id=player_id, name=player_name, db_id=db_id)
            game.add_player(player)

        # Set host status accurately
        player.is_host = (game.host_id == player_id)
            
        await game.save()
        return game

game_manager = GameManager()
