import os
from supabase import create_client, Client
from dotenv import load_dotenv
import re

# Run from backend directory
load_dotenv('.env')

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def cleanup_data():
    print(f"Starting cleanup for Eldritch Horror cards at {SUPABASE_URL}...")
    
    # 1. Fetch all Eldritch cards
    res = supabase.table("library_cards").select("*").eq("game_type", "eldritch_horror").execute()
    cards = res.data
    print(f"Found {len(cards)} cards.")

    # 2. Identify duplicates and malformed names
    # Strategy: Group by "base name" (removing trailing IDs like _123456)
    seen_names = {} # base_name -> list of card_ids
    
    for card in cards:
        orig_name = card["content"]
        # Regex to strip trailing _[0-9]{6} or similar patterns
        base_name = re.sub(r'_\d+$', '', orig_name).strip()
        
        if base_name not in seen_names:
            seen_names[base_name] = []
        seen_names[base_name].append(card)

    items_to_delete = []
    items_to_update = []

    for base_name, variations in seen_names.items():
        # If multiple variations or if the name needs cleaning
        # We want to keep the "best" one (closest to base_name and has metadata)
        
        # Sort variations: ones with exact base_name first, then ones with metadata
        variations.sort(key=lambda x: (x["content"] != base_name, x["metadata"] == {}))
        
        keep = variations[0]
        duplicates = variations[1:]
        
        # If the 'keep' item's name is NOT clean (e.g. still has ID but it's the only one), update it
        if keep["content"] != base_name:
            print(f"Cleaning name: '{keep['content']}' -> '{base_name}'")
            items_to_update.append({"id": keep["id"], "content": base_name})
            
        for dup in duplicates:
            print(f"Marking duplicate for deletion: '{dup['content']}' (ID: {dup['id']})")
            items_to_delete.append(dup["id"])

    # 3. Apply changes
    if items_to_delete:
        print(f"Deleting {len(items_to_delete)} duplicates...")
        for i in range(0, len(items_to_delete), 50):
            chunk = items_to_delete[i:i+50]
            supabase.table("library_cards").delete().in_("id", chunk).execute()

    if items_to_update:
        print(f"Updating {len(items_to_update)} names...")
        for item in items_to_update:
            supabase.table("library_cards").update({"content": item["content"]}).eq("id", item["id"]).execute()

    print("Cleanup complete.")

if __name__ == "__main__":
    cleanup_data()
