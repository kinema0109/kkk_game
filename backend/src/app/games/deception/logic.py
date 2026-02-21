from src.app.core.base_game import BaseRoom, BasePlayer
from src.app.api.schemas import GameStatus, Role, CardType
from src.app.core.database import get_supabase
from src.app.core.state_manager import RedisStateManager
from typing import Dict, Any, List, Optional
import random

state_manager = RedisStateManager(prefix="deception")

class DeceptionPlayer(BasePlayer):
    role: Optional[Role] = None
    seat_index: Optional[int] = None
    means_cards: List[str] = []
    clue_cards: List[str] = []
    has_badge: bool = True
    active_tiles: List[Dict[str, Any]] = [] # For Forensic Scientist

class DeceptionGame(BaseRoom):
    status: GameStatus = GameStatus.LOBBY
    round: int = 0
    murderer_id: Optional[str] = None
    means_id: Optional[str] = None
    clue_id: Optional[str] = None
    players: List[DeceptionPlayer] = []
    
    async def save(self):
        """Save the current game state to Redis."""
        await state_manager.set_state(self.room_id, self)

    def sync_to_supabase(self):
        """Sync critical game state to Supabase."""
        supabase = get_supabase()
        if not supabase:
            return
        
        try:
            # Sync Game status
            supabase.table('games').update({
                "status": self.status,
                "round": self.round,
                "solution_means_id": self.means_id,
                "solution_clue_id": self.clue_id,
                "solution_murderer_id": self.murderer_id
            }).eq('id', self.room_id).execute()
            
            # Sync Players (Roles, Ready status, etc.)
            for player in self.players:
                supabase.table('players').update({
                    "role": player.role,
                    "is_ready": player.is_ready,
                    "has_badge": player.has_badge
                }).eq('id', player.id).execute()
                
        except Exception as e:
            from src.app.core.logger import logger
            logger.error(f"Supabase sync error: {e}")

    async def start_game(self):
        if len(self.players) < 4:
            raise ValueError("Not enough players (min 4)")

        # ... (role assignment logic remains the same)

        # 1. Assign Roles
        shuffled_players = self.players.copy()
        random.shuffle(shuffled_players)
        
        # Forensic Scientist
        fs = shuffled_players.pop()
        fs.role = Role.FORENSIC_SCIENTIST
        
        # Murderer
        murderer = shuffled_players.pop()
        murderer.role = Role.MURDERER
        self.murderer_id = murderer.id
        
        # Accomplice (if 5+ players)
        if len(self.players) >= 5:
            accomplice = shuffled_players.pop()
            accomplice.role = Role.ACCOMPLICE
            
        # Witness
        witness = shuffled_players.pop()
        witness.role = Role.WITNESS
        
        # Rest are investigators
        for p in shuffled_players:
            p.role = Role.INVESTIGATOR
            
        # 2. Deal Cards (Drafting Phase)
        supabase = get_supabase()
        if supabase:
            # Note: In a real app, we'd fetch from library_cards
            # For now, we simulate or fetch if possible. 
            # Given the requirement to port, I should fetch.
            res = supabase.table('library_cards').select('id, type').execute()
            all_cards = res.data
            
            means_pool = [c['id'] for c in all_cards if c['type'] == CardType.MEANS]
            clue_pool = [c['id'] for c in all_cards if c['type'] == CardType.CLUE]
            
            random.shuffle(means_pool)
            random.shuffle(clue_pool)
            
            cards_per_player = 10
            non_fs_players = [p for p in self.players if p.role != Role.FORENSIC_SCIENTIST]
            
            game_cards_to_insert = []
            for i, p in enumerate(non_fs_players):
                means = means_pool[i*cards_per_player : (i+1)*cards_per_player]
                clues = clue_pool[i*cards_per_player : (i+1)*cards_per_player]
                p.means_cards = means
                p.clue_cards = clues
                
                # Prepare for Supabase insert
                for c_id in means + clues:
                    game_cards_to_insert.append({
                        "game_id": self.room_id,
                        "player_id": p.id,
                        "card_id": c_id
                    })
            
            # Sync to Supabase
            if game_cards_to_insert:
                # First cleanup existing game_cards (to be safe/atomic like original logic)
                supabase.table('game_cards').delete().eq('game_id', self.room_id).execute()
                supabase.table('game_cards').insert(game_cards_to_insert).execute()
        
        self.status = GameStatus.CARD_DRAFTING
        self.round = 1
        await self.save()
        self.sync_to_supabase()
        
    async def handle_event(self, player_id: str, event_type: str, data: Dict[str, Any]):
        player = self.get_player(player_id)
        if not player:
            return

        if event_type == "start_game":
            if player.is_host:
                await self.start_game()
        
        elif event_type == "join_seat":
            seat = data.get("seat_index")
            if seat is not None:
                player.seat_index = seat
        
        elif event_type == "confirm_draft":
            # Implementation of confirm-draft logic
            selected_means = data.get("selected_means", [])
            selected_clues = data.get("selected_clues", [])
            if len(selected_means) == 5 and len(selected_clues) == 5:
                player.means_cards = selected_means
                player.clue_cards = selected_clues
                player.is_ready = True
                
                # Check if all non-FS players are ready
                non_fs = [p for p in self.players if p.role != Role.FORENSIC_SCIENTIST]
                if all(p.is_ready for p in non_fs):
                    self.status = GameStatus.CRIME_SELECTION
                    for p in self.players:
                        p.is_ready = False
        
        elif event_type == "confirm_crime":
            if player.role != Role.MURDERER:
                return # Only murderer can confirm crime
            
            self.means_id = data.get("means_id")
            self.clue_id = data.get("clue_id")
            if self.means_id and self.clue_id:
                self.status = GameStatus.INVESTIGATION
                self.round = 1
        
        elif event_type == "solve":
            if not player.has_badge:
                return # Already used
            
            suspect_id = data.get("suspect_id")
            means_id = data.get("means_id")
            clue_id = data.get("clue_id")
            
            is_correct = (suspect_id == self.murderer_id and 
                          means_id == self.means_id and 
                          clue_id == self.clue_id)
            
            if is_correct:
                self.status = GameStatus.WITNESS_IDENTIFICATION
            else:
                # Investigator fails, loses badge
                player.has_badge = False
                
                # Check if all investigators/witnesses are out of badges
                remaining_badges = [p for p in self.players if p.role in [Role.INVESTIGATOR, Role.WITNESS] and p.has_badge]
                if not remaining_badges:
                    self.status = GameStatus.GAME_OVER
                    self.metadata["winner"] = "EVIL"

        elif event_type == "draw_tiles":
            if player.role != Role.FORENSIC_SCIENTIST:
                return
            
            supabase = get_supabase()
            if supabase:
                # Fetch available tiles
                res = supabase.table('library_tiles').select('*').execute()
                all_tiles = res.data
                random.shuffle(all_tiles)
                
                # Assign 6 initial tiles as per game rules
                # 1 Cause of Death + 1 Location + 4 Scene tiles
                cause_tiles = [t for t in all_tiles if t['type'] == 'CAUSE_OF_DEATH']
                location_tiles = [t for t in all_tiles if t['type'] == 'LOCATION']
                scene_tiles = [t for t in all_tiles if t['type'] == 'SCENE']
                
                selected = [cause_tiles[0], location_tiles[0]] + scene_tiles[:4]
                player.active_tiles = selected
                
        elif event_type == "select_tile_option":
            if player.role != Role.FORENSIC_SCIENTIST:
                return
            
            tile_id = data.get("tile_id")
            option_index = data.get("option_index")
            # Update tile state in metadata or player active_tiles
            for tile in player.active_tiles:
                if str(tile['id']) == str(tile_id):
                    tile['selected_option'] = option_index
                    break
            
        elif event_type == "identify_witness":
            if player.role != Role.MURDERER:
                return
            
            target_id = data.get("target_id")
            target = self.get_player(target_id)
            
            if target and target.role == Role.WITNESS:
                # Murderer escaped!
                self.status = GameStatus.GAME_OVER
                self.metadata["winner"] = "EVIL"
            else:
                # Murderer failed to find witness
                self.status = GameStatus.GAME_OVER
                self.metadata["winner"] = "GOOD"
            
        await self.save()
        self.sync_to_supabase()
        # TODO: Add Supabase sync for critical phase changes here
