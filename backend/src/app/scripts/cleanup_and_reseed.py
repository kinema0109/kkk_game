import os
import re
from supabase import create_client, Client
from dotenv import load_dotenv
from upload_and_seed_all_eldritch import upload_and_seed, sanitize_name

# Run from backend directory context
load_dotenv('.env')

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
GAME_TYPE = "eldritch_horror"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def cleanup_miscategorized():
    print("Performing full wipe of eldritch_horror cards for clean re-seed...")
    # Delete all to ensure new 4x4 classification is applied correctly
    res = supabase.table("library_cards").delete().eq("game_type", GAME_TYPE).execute()
    print(f"Cleanup finished. Deleted {len(res.data)} records.")

if __name__ == "__main__":
    # First cleanup the known bad data
    cleanup_miscategorized()
    
    # Then run the full upload and seed with improved logic
    upload_and_seed()
