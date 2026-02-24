import os
import json
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv(os.path.join(os.getcwd(), 'backend', '.env'))

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY") # Use Service Role for seeding

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Sample Data: High Quality English Cards
SAMPLE_CARDS = [
    {
        "type": "Investigator",
        "name": "Agnes Baker",
        "content": "The Waitress. Once, Agnes lived quietly, taking orders and serving up food at a diner in Arkham...",
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
        "type": "Ancient One",
        "name": "Azathoth",
        "content": "The Daemon Sultan. It is said that the universe is but a dream of Azathoth...",
        "metadata": {
            "title": "The Daemon Sultan",
            "doom": 15,
            "gameplay": "When the Omen advances to the green space, advance Doom by 1 for each Eldritch token.",
            "expansion": "Base"
        }
    },
    {
        "type": "Common Item",
        "name": "+.38 Revolver",
        "content": "A reliable firearm.",
        "metadata": {
            "cost": 2,
            "categories": ["Object", "Weapon"],
            "effect": "Gain +2 Strength during Combat Encounters.",
            "icon_id": "pistol"
        }
    },
    {
        "type": "Spell",
        "name": "Flesh Ward",
        "content": "A protective incantation.",
        "metadata": {
            "type": "Incantation",
            "effect": "Action: Test Lore (+0). On success, gain a Physical Ward token.",
            "expansion": "Base",
            "icon_id": "shield"
        }
    },
    {
        "type": "Condition",
        "name": "Leg Injury",
        "content": "Your leg is badly hurt.",
        "metadata": {
            "type": "Injury",
            "effect": "You cannot perform Move actions more than once per turn.",
            "reckoning": "Test Strength. On failure, flip this card."
        }
    }
]

def seed_samples():
    print(f"Seeding samples to {SUPABASE_URL}...")
    
    for card in SAMPLE_CARDS:
        data = {
            "type": card["type"],
            "name": card["name"],
            "content": card["content"],
            "metadata": card["metadata"],
            "game_type": "eldritch_horror"
        }
        
        # Upsert based on name
        response = supabase.table("library_cards").upsert(
            data, 
            on_conflict="name"
        ).execute()

    print(f"Successfully seeded {len(SAMPLE_CARDS)} Eldritch Horror samples.")

if __name__ == "__main__":
    seed_samples()
