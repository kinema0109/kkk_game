from src.app.core.base_game import BaseRoom, BasePlayer
from src.app.api.schemas import GameStatus, Role, CardType, ChatMessage
from src.app.core.database import get_supabase
from src.app.core.state_manager import RedisStateManager
from typing import Dict, Any, List, Optional
import random
import time
import asyncio

state_manager = RedisStateManager(prefix="deception")

class DeceptionPlayer(BasePlayer):
    role: Optional[Role] = None
    seat_index: Optional[int] = None
    means_cards: List[str] = []
    clue_cards: List[str] = []
    has_badge: bool = True
    active_tiles: List[Dict[str, Any]] = [] # For Forensic Scientist
    draft_pool_means: List[str] = [] # Pool of 10 to choose 5 from
    draft_pool_clues: List[str] = [] # Pool of 10 to choose 5 from
    has_drafted: bool = False
    tiles_replaced: int = 0

class DeceptionGame(BaseRoom):
    status: GameStatus = GameStatus.LOBBY
    round: int = 0
    murderer_id: Optional[str] = None
    means_id: Optional[str] = None
    clue_id: Optional[str] = None
    players: List[DeceptionPlayer] = []

    def to_game_state(self, viewer_id: str = None):
        """Convert DeceptionGame to the API GameState schema with role filtering."""
        from src.app.api.schemas import GameState, Player as PlayerSchema
        
        viewer = self.get_player(viewer_id) if viewer_id else None
        viewer_role = viewer.role if viewer else None

        if not hasattr(DeceptionGame, "_card_cache"):
            DeceptionGame._card_cache = {}
            DeceptionGame._tile_cache = {}
            supabase = get_supabase()
            if supabase:
                # Cache cards
                res_cards = supabase.table('library_cards').select('id, content, image_url').execute()
                if res_cards and res_cards.data:
                    DeceptionGame._card_cache = {str(c['id']): c for c in res_cards.data}
                
                # Cache tiles
                res_tiles = supabase.table('library_tiles').select('id, name').execute()
                if res_tiles and res_tiles.data:
                    DeceptionGame._tile_cache = {str(t['id']): t for t in res_tiles.data}

        # Fetch avatars from profiles table
        profile_map = {}
        supabase = get_supabase()
        if supabase:
            player_ids = [p.id for p in self.players]
            res_profiles = supabase.table('profiles').select('id, avatar_url').in_('id', player_ids).execute()
            if res_profiles and res_profiles.data:
                profile_map = {p['id']: p.get('avatar_url') for p in res_profiles.data}

        # Convert DeceptionPlayers to API PlayerSchema with role filtering
        api_players = []
        for p in self.players:
            # Determine if the viewer can see this player's role
            should_see_role = False
            
            if viewer_id == p.id:
                should_see_role = True # Player sees their own role
            elif viewer_role == Role.FORENSIC_SCIENTIST:
                should_see_role = True # FS sees everyone
            elif viewer_role in [Role.MURDERER, Role.ACCOMPLICE] and p.role in [Role.MURDERER, Role.ACCOMPLICE, Role.FORENSIC_SCIENTIST]:
                should_see_role = True # EVIL sees each other and FS
            elif viewer_role == Role.WITNESS and p.role == Role.MURDERER:
                # Witness only sees the Murderer
                should_see_role = True
            elif p.role == Role.FORENSIC_SCIENTIST:
                should_see_role = True # Everyone knows who the FS is

            # Enrich cards with metadata
            def enrich_cards(card_ids):
                enriched = []
                for cid in card_ids:
                    card_data = DeceptionGame._card_cache.get(cid, {"id": cid, "content": "Unknown", "image_url": None})
                    enriched.append({
                        "id": cid,
                        "name": card_data.get("name") or card_data.get("content") or cid,
                        "content": card_data.get("content"),
                        "image_url": card_data.get("image_url")
                    })
                return enriched

            api_players.append(
                PlayerSchema(
                    id=p.id,
                    name=p.name,
                    is_host=p.is_host,
                    is_ready=p.is_ready,
                    metadata={
                        "role": (p.role.value if p.role else None) if should_see_role else "UNKNOWN",
                        "avatar_url": profile_map.get(str(p.id)),
                        "seat_index": p.seat_index,
                        "has_badge": p.has_badge,
                        "means_cards": enrich_cards(p.means_cards),
                        "clue_cards": enrich_cards(p.clue_cards),
                        "draft_means": enrich_cards(p.draft_pool_means) if viewer_id == p.id else [],
                        "draft_clues": enrich_cards(p.draft_pool_clues) if viewer_id == p.id else [],
                        "has_drafted": p.has_drafted,
                        "tiles_replaced": p.tiles_replaced,
                        "active_tiles": [
                            {
                                **t,
                                "image_url": DeceptionGame._tile_cache.get(str(t['id']), {}).get('image_url')
                            } for t in p.active_tiles
                        ]
                    }
                )
            )
        
        # Determine visibility of crime info
        show_crime = False
        if viewer_role in [Role.FORENSIC_SCIENTIST, Role.MURDERER]:
            show_crime = True
        elif viewer_role == Role.ACCOMPLICE and self.status != GameStatus.CRIME_SELECTION:
            show_crime = True # Accomplice sees it after it's chosen
        elif self.status == GameStatus.GAME_OVER:
            show_crime = True # Everyone sees it at the end

        # Prepare game-specific data for the 'data' field
        def get_card_obj(cid):
            if not cid: return None
            card_data = DeceptionGame._card_cache.get(cid, {"id": cid, "name": cid, "content": "Unknown", "image_url": None})
            return {
                "id": cid,
                "name": card_data.get("name") or card_data.get("content") or cid,
                "content": card_data.get("content"),
                "image_url": card_data.get("image_url")
            }

        game_data = {
            "round": self.round,
            "murderer_id": self.murderer_id if viewer_role in [Role.FORENSIC_SCIENTIST, Role.MURDERER, Role.ACCOMPLICE] else None,
            "means_id": self.means_id if show_crime else None,
            "clue_id": self.clue_id if show_crime else None,
            "means_card": get_card_obj(self.means_id) if show_crime else None,
            "clue_card": get_card_obj(self.clue_id) if show_crime else None,
            "metadata": self.metadata
        }
        
        return GameState(
            room_id=self.room_id,
            status=self.status,
            players=api_players,
            current_turn_owner=None,
            data=game_data
        )

    async def broadcast_state(self):
        """Broadcast individualized game states to each connected client."""
        from src.app.api.websocket import manager
        from src.app.api.schemas import GameUpdateMessage, MessageType
        
        try:
            # We must iterate over all known players in the game who might be connected
            for player in self.players:
                state = self.to_game_state(viewer_id=player.id)
                msg = GameUpdateMessage(
                    type=MessageType.GAME_UPDATE,
                    timestamp=time.time(),
                    state=state
                )
                await manager.send_to_user(msg.model_dump(), self.room_id, player.id)
        except Exception as e:
            from src.app.core.logger import logger
            logger.error(f"Error broadcasting state for room {self.room_id}: {e}")
    
    async def save(self):
        """Save the current game state to Redis."""
        await state_manager.set_state(self.room_id, self)

    def sync_to_supabase(self):
        """Sync critical game state to Supabase."""
        supabase = get_supabase()
        if not supabase:
            return
        
        try:
            # Sync Game status and metadata
            supabase.table('games').update({
                "status": self.status.value,
                "metadata": {
                    "round": self.round,
                    "solution_means_id": self.means_id,
                    "solution_clue_id": self.clue_id,
                    "solution_murderer_id": self.murderer_id,
                    "winner": self.metadata.get("winner")
                }
            }).eq('id', self.room_id).execute()
            
            # Sync Players (Generic fields + metadata)
            for player in self.players:
                if not player.db_id:
                    continue
                    
                supabase.table('players').update({
                    "is_ready": player.is_ready,
                    "metadata": {
                        "role": player.role.value if player.role else None,
                        "has_badge": player.has_badge,
                        "seat_index": player.seat_index,
                        "means_cards": player.means_cards,
                        "clue_cards": player.clue_cards,
                        "active_tiles": player.active_tiles
                    }
                }).eq('id', player.db_id).execute()
                
        except Exception as e:
            from src.app.core.logger import logger
            logger.error(f"Supabase sync error: {e}")

    async def start_game(self):
        if len(self.players) < 4:
            raise ValueError("Not enough players (min 4)")

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
            res = supabase.table('library_cards').select('id, type').execute()
            if res is None:
                from src.app.core.logger import logger
                logger.error("Supabase cards fetch returned None in start_game")
                return
            all_cards = res.data
            
            means_pool = [c['id'] for c in all_cards if str(c['type']).upper() == CardType.MEANS.value]
            clue_pool = [c['id'] for c in all_cards if str(c['type']).upper() == CardType.CLUE.value]
            
            random.shuffle(means_pool)
            random.shuffle(clue_pool)
            
            non_fs_players = [p for p in self.players if p.role != Role.FORENSIC_SCIENTIST]
            num_suspects = len(non_fs_players)
            
            game_cards_to_insert = []
            for i, p in enumerate(non_fs_players):
                # 10/10 pool for everyone
                # We need enough cards for all players
                p.draft_pool_means = random.sample(means_pool, min(len(means_pool), 10))
                p.draft_pool_clues = random.sample(clue_pool, min(len(clue_pool), 10))
                p.means_cards = []
                p.clue_cards = []
                p.has_drafted = False
            
            # Sync to Supabase
            if game_cards_to_insert:
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
            if not player.is_host:
                from src.app.core.logger import logger
                logger.warning(f"Unauthorized start_game attempt by {player_id}")
                return # Forbidden
            await self.start_game()
        
        elif event_type == "reset_game":
            if not player.is_host and self.status != GameStatus.GAME_OVER:
                return
            await self.reset_game()
        
        elif event_type == "ready":
            player.is_ready = not player.is_ready

        elif event_type == "chat":
            from src.app.api.websocket import manager
            msg_text = data.get("message")
            if msg_text:
                chat_msg = ChatMessage(
                    player_id=player_id,
                    player_name=player.name,
                    message=msg_text,
                    is_system=data.get("is_system", False),
                    timestamp=time.time()
                )
                # Persist to DB
                supabase = get_supabase()
                if supabase:
                    supabase.from_("game_chats").insert({
                        "game_id": self.room_id,
                        "player_id": player_id,
                        "player_name": player.name,
                        "message": msg_text,
                        "is_system": chat_msg.is_system
                    }).execute()
                
                # Broadcast
                await manager.broadcast(chat_msg.model_dump(), self.room_id)

        elif event_type == "reset":
            if not player.is_host:
                return
            await self.reset_game()

        elif event_type == "leave":
            is_host = player.is_host
            # Logic for removing player from state
            self.players = [p for p in self.players if p.id != player_id]
            
            if is_host:
                from src.app.core.logger import logger
                logger.info(f"Host {player_id} left room {self.room_id}. Purging room.")
                await self.close_game()
                return # Exit early as room is deleted
            elif not self.players:
                # Cleanup empty room
                await self.close_game()
                return
        
        elif event_type == "join_seat":
            seat = data.get("seat_index")
            if seat is not None:
                player.seat_index = seat
        
        elif event_type == "confirm_draft":
            # Implementation of confirm-draft logic
            selected_means = data.get("selected_means", [])
            selected_clues = data.get("selected_clues", [])
            if len(selected_means) == 5 and len(selected_clues) == 5:
                # Validate that selected cards are in the draft pool
                if all(mid in player.draft_pool_means for mid in selected_means) and \
                   all(cid in player.draft_pool_clues for cid in selected_clues):
                    
                    player.means_cards = selected_means
                    player.clue_cards = selected_clues
                    player.has_drafted = True
                    
                    # Sync this player's cards to Supabase
                    supabase = get_supabase()
                    target_player_id = player.db_id or player_id # Use DB UUID if available
                    if supabase:
                        game_cards = []
                        for cid in selected_means + selected_clues:
                            game_cards.append({
                                "game_id": self.room_id,
                                "player_id": target_player_id,
                                "card_id": cid
                            })
                        # Delete old (if any) and insert new
                        supabase.table('game_cards').delete().eq('game_id', self.room_id).eq('player_id', target_player_id).execute()
                        supabase.table('game_cards').insert(game_cards).execute()

                    # Check if all suspects are done drafting
                    suspects = [p for p in self.players if p.role != Role.FORENSIC_SCIENTIST]
                    if all(p.has_drafted for p in suspects):
                        self.status = GameStatus.CRIME_SELECTION
                        await self.save()
                        # Notify murder committing
                        from src.app.api.websocket import manager
                        await manager.broadcast({
                            "type": "CHAT",
                            "message": "All suspects have chosen their equipment. The crime is being committed...",
                            "is_system": True,
                            "timestamp": time.time()
                        }, self.room_id)

                    await self.save()
                    self.sync_to_supabase()
                
        elif event_type == "confirm_crime":
            if player.role != Role.MURDERER:
                return # Only murderer can confirm crime
            
            self.means_id = data.get("means_id")
            self.clue_id = data.get("clue_id")
            if self.means_id and self.clue_id:
                self.status = GameStatus.FORENSIC_SETUP
                self.round = 1
                
                # Trigger FS to draw initial tiles
                fs = next((p for p in self.players if p.role == Role.FORENSIC_SCIENTIST), None)
                if fs:
                    await self._draw_initial_tiles(fs)
        
        elif event_type == "confirm_tiles":
            if player.role != Role.FORENSIC_SCIENTIST:
                return
            
            # Transition to investigation after tiles are ready
            self.status = GameStatus.INVESTIGATION
        
        elif event_type == "solve":
            if not player.has_badge or player.role == Role.FORENSIC_SCIENTIST:
                return # Already used or Forensic Scientist cannot solve
            
            suspect_id = data.get("suspect_id") or data.get("murderer_id")
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
        
        elif event_type == "replace_tile":
            if player.role != Role.FORENSIC_SCIENTIST or player.tiles_replaced >= 2:
                return
            
            tile_id = data.get("tile_id")
            if not tile_id:
                return
                
            # Draw a replacement SCENE tile
            supabase = get_supabase()
            if supabase:
                res = supabase.table('library_tiles').select('id, name, type, options').eq('type', 'SCENE').execute()
                if res and res.data:
                    # Filter out current active tiles to avoid duplicates
                    current_ids = [str(t['id']) for t in player.active_tiles]
                    pool = [t for t in res.data if str(t['id']) not in current_ids]
                    if pool:
                        new_tile = random.choice(pool)
                        # Replace the tile
                        for i, tile in enumerate(player.active_tiles):
                            if str(tile['id']) == str(tile_id):
                                player.active_tiles[i] = {
                                    "id": str(new_tile["id"]),
                                    "title": new_tile["name"],
                                    "type": new_tile["type"],
                                    "options": new_tile["options"],
                                    "selected_option": None
                                }
                                player.tiles_replaced += 1
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
        await self.broadcast_state()

    async def _draw_initial_tiles(self, fs_player):
        supabase = get_supabase()
        if not supabase:
            return
            
        res = supabase.table('library_tiles').select('id, name, type, options').execute()
        if not res or not res.data:
            return
            
        all_tiles = res.data
        random.shuffle(all_tiles)
        
        cause_tiles = [t for t in all_tiles if t['type'] == 'CAUSE_OF_DEATH']
        location_tiles = [t for t in all_tiles if t['type'] == 'LOCATION']
        scene_tiles = [t for t in all_tiles if t['type'] == 'SCENE']
        
        if not cause_tiles or not location_tiles or len(scene_tiles) < 4:
            return
            
        selected = [cause_tiles[0], location_tiles[0]] + scene_tiles[:4]
        
        fs_player.active_tiles = [
            {
                "id": str(t["id"]),
                "title": t["name"],
                "type": t["type"],
                "options": t["options"],
                "selected_option": None
            }
            for t in selected
        ]

    async def close_game(self):
        """Hard deletes the game from database and cache."""
        supabase = get_supabase()
        if supabase:
            # 1. Delete players in this game first to avoid orphaned references
            supabase.table('players').delete().eq('game_id', self.room_id).execute()
            # 2. Delete game itself
            supabase.table('games').delete().eq('id', self.room_id).execute()
        
        await state_manager.delete_state(self.room_id)
        from src.app.core.logger import logger
        logger.info(f"Game room {self.room_id} has been fully closed and purged.")

    async def reset_game(self):
        """Wipes the game state back to LOBBY."""
        supabase = get_supabase()
        if not supabase:
            return
            
        # 1. DB Cleanup
        supabase.table('games').update({
            "status": GameStatus.LOBBY.value,
            "metadata": {}
        }).eq('id', self.room_id).execute()
        
        # Parallel delete related data
        supabase.table('game_cards').delete().eq('game_id', self.room_id).execute()
        supabase.table('game_tiles').delete().eq('game_id', self.room_id).execute()
        supabase.table('game_chats').delete().eq('game_id', self.room_id).execute()
        
        # 2. State Reset
        self.status = GameStatus.LOBBY
        self.round = 0
        self.murderer_id = None
        self.means_id = None
        self.clue_id = None
        
        for p in self.players:
            p.role = None
            p.is_ready = False
            p.has_badge = True
            p.means_cards = []
            p.clue_cards = []
            
        await self.save()
        self.sync_to_supabase()
        await self.broadcast_state()
