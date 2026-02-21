import asyncio
import sys
from pathlib import Path

# Add backend root to sys.path to allow imports
sys.path.append(str(Path(__file__).parent.parent.parent.parent))

from src.app.core.config import settings
from src.app.core.logger import logger

async def migrate_admin():
    """Migrate all users: ADMIN_EMAIL to admin, others to user."""
    logger.info("Starting RBAC Migration...")
    
    admin_email = settings.ADMIN_EMAIL
    if not admin_email:
        logger.warning("ADMIN_EMAIL not set in environment. Skipping admin migration.")
        return

    logger.info(f"Targeting ADMIN_EMAIL: {admin_email}")
    
    try:
        from gotrue import SyncGoTrueClient
        
        # Use Service Role Key if available, otherwise fallback to SUPABASE_KEY
        url = settings.SUPABASE_URL
        key = settings.SUPABASE_SERVICE_ROLE_KEY or settings.SUPABASE_KEY
        
        if not url or not key:
             logger.error("SUPABASE_URL or SUPABASE_KEY/SUPABASE_SERVICE_ROLE_KEY missing.")
             return

        auth = SyncGoTrueClient(
            url=f"{url}/auth/v1",
            headers={"Authorization": f"Bearer {key}", "apikey": key}
        )
        
        logger.info(f"Connected to GoTrue at {url}")

        # 1. Get all users
        users = auth.admin.list_users()
        logger.info(f"Found {len(users)} users in Supabase.")

        for user in users:
            target_role = "admin" if user.email == admin_email else "user"
            current_role = user.app_metadata.get('role')
            
            if current_role != target_role:
                auth.admin.update_user_by_id(
                    user.id,
                    {"app_metadata": {"role": target_role}}
                )
                logger.info(f"Updated {user.email}: {current_role} -> {target_role}")
            else:
                logger.debug(f"Skipped {user.email}: already has role {target_role}")

        logger.info("RBAC Migration completed successfully.")

    except ImportError:
        logger.error("gotrue package not found. Please run 'uv add gotrue'.")
    except Exception as e:
        logger.error(f"RBAC Migration failed: {e}")

if __name__ == "__main__":
    asyncio.run(migrate_admin())
