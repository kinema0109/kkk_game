import os
import re
from supabase import create_client, Client
from dotenv import load_dotenv

# Load env from backend folder
load_dotenv(dotenv_path='./backend/.env')

url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(url, key)

ASSET_DIR = r"E:\image\eldrich horror\new"
BUCKET_NAME = "eldritch-assets"
GAME_TYPE = "eldritch_horror"

# Mapping from filename keywords to card_type enum
TYPE_MAPPING = {
    "Item": "ITEM",
    "Spell": "SPELL",
    "Ritual": "SPELL",
    "Incantation": "SPELL",
    "Glamour": "SPELL",
    "Condition": "CONDITION",
    "Boon": "CONDITION",
    "Curse": "CONDITION",
    "Injury": "CONDITION",
    "Monster": "MONSTER",
    "Ancient": "ANCIENT_ONE",
    "Investigator": "INVESTIGATOR",
    "Character": "INVESTIGATOR",
    "Portrait": "INVESTIGATOR",
    "Encounter": "ENCOUNTER",
    "Artifact": "ITEM",
    "Trinket": "ITEM",
    "Weapon": "ITEM",
}

def parse_filename(filename):
    # Remove extension
    name_base = os.path.splitext(filename)[0]
    
    # Split by " - "
    parts = name_base.split(" - ")
    display_name = parts[0]
    
    # Default type
    card_type = "ENCOUNTER" # Fallback
    
    tags = []
    if len(parts) > 1:
        # Keywords after the dash, separated by comma
        keywords = [k.strip() for k in parts[1].split(",")]
        tags = keywords
        
        # Try to find a matching card type from keywords
        for k in keywords:
            for key, val in TYPE_MAPPING.items():
                if key.lower() in k.lower():
                    card_type = val
                    break
    
    # Check if name itself implies type (e.g. for Investigators which might not have " - Investigator")
    if card_type == "ENCOUNTER":
        for key, val in TYPE_MAPPING.items():
             if key.lower() in display_name.lower():
                    card_type = val
                    break

    return display_name, card_type, tags

def seed_cards():
    files = [f for f in os.listdir(ASSET_DIR) if f.lower().endswith('.webp')]
    total = len(files)
    count = 0
    
    print(f"Seeding {total} cards into library_cards...")

    for filename in files:
        display_name, card_type, tags = parse_filename(filename)
        
        # Construct public URL for the image
        # Format: https://xeiezdokmvvsxwtgbiep.supabase.co/storage/v1/object/public/eldritch-assets/filename
        image_url = f"{url}/storage/v1/object/public/{BUCKET_NAME}/{filename}"

        card_data = {
            "game_type": GAME_TYPE,
            "type": card_type,
            "content": display_name,
            "image_url": image_url,
            "metadata": {
                "tags": tags,
                "original_filename": filename
            }
        }

        try:
            # Insert card record. Upsert based on image_url or content if desired.
            # Here we just insert.
            res = supabase.table("library_cards").insert(card_data).execute()
            count += 1
            if count % 50 == 0:
                print(f"Inserted {count}/{total}...")
        except Exception as e:
            print(f"Error seeding {filename}: {e}")

    print(f"\nSeeding complete! Total cards inserted: {count}")

if __name__ == "__main__":
    seed_cards()
