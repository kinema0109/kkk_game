from typing import List, Dict, Any, Optional
from .logic import DeceptionGame, DeceptionPlayer

class GameManager:
    def __init__(self):
        self.games: Dict[str, DeceptionGame] = {}

    def create_game(self, room_id: str, room_code: str) -> DeceptionGame:
        game = DeceptionGame(room_id=room_id, room_code=room_code)
        self.games[room_id] = game
        return game

    def get_game(self, room_id: str) -> Optional[DeceptionGame]:
        return self.games.get(room_id)

    def handle_player_connect(self, room_id: str, player_id: str, player_name: str) -> DeceptionGame:
        game = self.get_game(room_id)
        if not game:
            game = self.create_game(room_id, room_id)
            
        player = game.get_player(player_id)
        if player:
            player.is_online = True
        else:
            player = DeceptionPlayer(id=player_id, name=player_name)
            game.add_player(player)
            
        return game

game_manager = GameManager()
