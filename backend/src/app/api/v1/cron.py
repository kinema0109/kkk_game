from fastapi import APIRouter, BackgroundTasks, Depends
from src.app.core.database import get_supabase
from src.app.api.schemas import GameStatus
from src.app.core.i18n import get_translator, Translator
import time

router = APIRouter(prefix="/cron", tags=["Cron"])

@router.get("/cleanup", summary="Automated maintenance")
async def cleanup(background_tasks: BackgroundTasks, t: Translator = Depends(get_translator)):
    """Cleanup stale games and inactive players."""
    from src.app.core.database import get_supabase
    supabase = get_supabase()
    # Placeholder for actual cleanup logic (e.g., delete games > 24h old)
    return {"status": t.t("cron.cleanup_triggered")}
