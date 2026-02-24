import os
import json
from supabase import create_client, Client
from dotenv import load_dotenv

# Run from backend directory
load_dotenv('.env')

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

BASE_URL = f"{SUPABASE_URL}/storage/v1/object/public/eldritch-assets/"

# Sample Data: High Quality English Cards
SAMPLE_CARDS = [
    {
        "type": "INVESTIGATOR",
        "name": "Agnes Baker",
        "image_url": f"{BASE_URL}Agnes Baker.webp",
        "description": "The Waitress. Once, Agnes lived quietly, taking orders and serving up food at a diner in Arkham...",
        "metadata": {
            "title": "The Waitress",
            "stats": {"health": 7, "sanity": 5, "lore": 4, "influence": 3, "observation": 2, "strength": 2, "will": 2},
            "abilities": [
                "Action: Test Lore -1. If you pass, gain 1 Spell.",
                "Spend 1 Health to roll 2 additional dice for Lore tests in Spell effects."
            ],
            "quote": "I remember another life, one of sorcery and conquest.",
            "expansion": "Base"
        }
    },
    {
        "type": "ANCIENT_ONE",
        "name": "Azathoth",
        "image_url": f"{BASE_URL}Azathoth.webp",
        "description": "The Daemon Sultan. It is said that the universe is but a dream of Azathoth...",
        "metadata": {
            "title": "The Daemon Sultan",
            "doom": 15,
            "gameplay": "When the Omen advances to the green space, advance Doom by 1 for each Eldritch token.",
            "expansion": "Base"
        }
    },
    {
        "type": "CONDITION",
        "name": "Leg Injury",
        "image_url": f"{BASE_URL}Leg Injury - Injury.webp",
        "description": "Your leg is badly hurt.",
        "metadata": {
            "sub_type": "Injury",
            "effect": "You cannot perform Move actions more than once per turn.",
            "reckoning": "Test Strength. On failure, flip this card."
        }
    }
]

def seed_samples():
    print(f"Updating samples with URLs at {SUPABASE_URL}...")
    
    for card in SAMPLE_CARDS:
        data = {
            "type": card["type"],
            "content": card["name"],
            "image_url": card["image_url"],
            "metadata": {
                "description": card.get("description", ""),
                **card["metadata"]
            },
            "game_type": "eldritch_horror"
        }
        
        # Upsert based on name & game_type
        res = supabase.table("library_cards").select("id").eq("content", card["name"]).eq("game_type", "eldritch_horror").execute()
        
        if res.data:
            card_id = res.data[0]["id"]
            print(f"Updating {card['name']} with image ({card['image_url']})...")
            supabase.table("library_cards").update(data).eq("id", card_id).execute()
        else:
            print(f"Inserting {card['name']}...")
            supabase.table("library_cards").insert(data).execute()

    print(f"Successfully updated Eldritch Horror samples with image URLs.")

if __name__ == "__main__":
    seed_samples()
