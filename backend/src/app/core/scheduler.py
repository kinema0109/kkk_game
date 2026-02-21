from apscheduler.schedulers.asyncio import AsyncIOScheduler
from .logger import logger
import time

scheduler = AsyncIOScheduler()

async def cleanup_inactive_rooms():
    """
    Task to clean up inactive/abandoned game rooms.
    """
    from src.app.games.deception.manager import game_manager
    
    now = time.time()
    stale_threshold = 3600  # 1 hour
    
    rooms_to_remove = []
    for room_id, game in game_manager.games.items():
        # If no players are online and the room has been inactive for a while
        online_players = [p for p in game.players if p.is_online]
        if not online_players and (now - game.created_at) > stale_threshold:
            rooms_to_remove.append(room_id)
            
    for room_id in rooms_to_remove:
        logger.info(f"Scavenger: Removing stale room {room_id}")
        del game_manager.games[room_id]

def start_scheduler():
    if not scheduler.running:
        scheduler.add_job(cleanup_inactive_rooms, "interval", minutes=1)
        scheduler.start()
        logger.info("Scheduler started: Running periodic cleanup tasks.")

def stop_scheduler():
    if scheduler.running:
        scheduler.shutdown()
        logger.info("Scheduler stopped.")
