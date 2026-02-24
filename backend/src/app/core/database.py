from supabase import create_client, Client
from .config import settings
from .logger import logger

supabase: Client = None

def init_supabase():
    global supabase
    if settings.SUPABASE_URL and settings.SUPABASE_KEY:
        try:
            supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
            logger.info("Supabase client initialized successfully.")
        except Exception as e:
            logger.error(f"Failed to initialize Supabase client: {e}")
    else:
        logger.warning("Supabase credentials missing. Database features will be limited.")

def get_supabase() -> Client:
    if supabase is None:
        from fastapi import HTTPException
        logger.error("get_supabase called before initialization or initialization failed")
        raise HTTPException(status_code=500, detail="Supabase client not initialized")
    return supabase
