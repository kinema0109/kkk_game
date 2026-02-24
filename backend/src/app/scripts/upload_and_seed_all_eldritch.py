import os
import re
from supabase import create_client, Client
from dotenv import load_dotenv

# Run from backend directory
load_dotenv('.env')

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
ASSET_DIR = r"E:\image\eldrich horror"
BUCKET_NAME = "eldritch-assets"
GAME_TYPE = "eldritch_horror"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Definitive Mapping from keywords to sub_type detail
# Priority is determined by order: put more specific types first
SUB_TYPE_MAPPING = {
    # 1. ENCOUNTER (4x4: LOCATION, RESEARCH, OTHER_WORLD, EXPEDITION)
    "Research": "RESEARCH_ENCOUNTER",
    "Clue": "RESEARCH_ENCOUNTER",
    "Other World": "OTHER_WORLD_ENCOUNTER",
    "Gate": "OTHER_WORLD_ENCOUNTER",
    "Dreamlands": "OTHER_WORLD_ENCOUNTER",
    "Dream Quest": "OTHER_WORLD_ENCOUNTER",
    "Expedition": "EXPEDITION_ENCOUNTER",
    "Active Expedition": "EXPEDITION_ENCOUNTER",
    "Location": "LOCATION_ENCOUNTER",
    "City": "LOCATION_ENCOUNTER",
    "Wilderness": "LOCATION_ENCOUNTER",
    "Sea": "LOCATION_ENCOUNTER",
    "Mystic Ruins": "LOCATION_ENCOUNTER",
    "Devastation": "LOCATION_ENCOUNTER",
    "Disaster": "LOCATION_ENCOUNTER",
    
    # 2. ASSET - WEAPON
    "Weapon": "WEAPON",
    "Shotgun": "WEAPON",
    "Pistol": "WEAPON",
    "Revolver": "WEAPON",
    "Rifle": "WEAPON",
    "Gun": "WEAPON",
    "Blade": "WEAPON",
    "Axe": "WEAPON",
    "Sword": "WEAPON",
    "Knife": "WEAPON",
    ".38": "WEAPON",
    ".45": "WEAPON",
    ".18": "WEAPON",
    "Battery": "WEAPON", # Usually part of a weapon or gadget
    
    # 3. ASSET - ALLY
    "Ally": "ALLY",
    "Assistant": "ALLY",
    "Agent": "ALLY",
    "Hired": "ALLY",
    "Consultant": "ALLY",
    "Specialist": "ALLY",
    "Personal": "ALLY",
    "Cat Burglar": "ALLY",
    
    # 4. ASSET - SERVICE
    "Service": "SERVICE",
    "Charter": "SERVICE",
    "Blessing": "SERVICE",
    "Ticket": "SERVICE",
    "Hospital": "SERVICE",
    "Asylum": "SERVICE",
    "Hire": "SERVICE",
    "Loan": "SERVICE",
    
    # 5. ASSET - ITEM
    "Trinket": "ITEM",
    "Lantern": "ITEM",
    "Map": "ITEM",
    "Relic": "ITEM",
    "Tome": "ITEM",
    "Book": "ITEM",
    "Whiskey": "ITEM",
    "Pocket Watch": "ITEM",
    "Artifact": "ITEM",
    "Item": "ITEM",
    "Unique Asset": "ITEM",
    
    # 6. LOCATION NAMES
    "Arkham": "LOCATION_ENCOUNTER",
    "London": "LOCATION_ENCOUNTER",
    "Rome": "LOCATION_ENCOUNTER",
    "Istanbul": "LOCATION_ENCOUNTER",
    "Shanghai": "LOCATION_ENCOUNTER",
    "Tokyo": "LOCATION_ENCOUNTER",
    "San Francisco": "LOCATION_ENCOUNTER",
    "Buenos Aires": "LOCATION_ENCOUNTER",
    "Sydney": "LOCATION_ENCOUNTER",
    "Amazon": "LOCATION_ENCOUNTER",
    "Heart of Africa": "LOCATION_ENCOUNTER",
    "Himalayas": "LOCATION_ENCOUNTER",
    "Tunguska": "LOCATION_ENCOUNTER",
    "Pyramids": "LOCATION_ENCOUNTER",
    "Antarctica": "LOCATION_ENCOUNTER",
    "Africa": "LOCATION_ENCOUNTER",
    "Europe": "LOCATION_ENCOUNTER",
    "Asia": "LOCATION_ENCOUNTER",
    "America": "LOCATION_ENCOUNTER",
    "Egypt": "LOCATION_ENCOUNTER",
}

# Mapping sub_types back to existing Database Enum values
# Standard valid types that exist in the DB Enum
STABLE_TYPES = ["INVESTIGATOR", "ANCIENT_ONE", "ENCOUNTER", "MONSTER", "CONDITION", "SPELL", "ITEM", "MYSTERY", "MYTHOS"]

ENUM_MAPPING = {
    "WEAPON": "ITEM",
    "ITEM": "ITEM",
    "ALLY": "ITEM",
    "SERVICE": "ITEM",
    "LOCATION_ENCOUNTER": "ENCOUNTER",
    "RESEARCH_ENCOUNTER": "ENCOUNTER",
    "OTHER_WORLD_ENCOUNTER": "ENCOUNTER",
    "EXPEDITION_ENCOUNTER": "ENCOUNTER",
}

def get_enum_type(sub_type):
    if sub_type in STABLE_TYPES:
        return sub_type
    return ENUM_MAPPING.get(sub_type, "ITEM")

DIRECT_TYPE_MAPPING = {
    "Ancient One": "ANCIENT_ONE",
    "Monster": "MONSTER",
    "Condition": "CONDITION",
    "Spell": "SPELL",
    "Epic Monster": "MONSTER",
    "Boss": "MONSTER",
    "Ancient": "ANCIENT_ONE",
    "Ritual": "SPELL",
    "Incantation": "SPELL",
    "Glamour": "SPELL",
    "Injury": "CONDITION",
    "Madness": "CONDITION",
    "Boon": "CONDITION",
    "Bane": "CONDITION",
    "Illness": "CONDITION",
    "Exposure": "CONDITION",
    "Addiction": "CONDITION",
    "Determination": "CONDITION",
    "Deal": "CONDITION",
    "Restriction": "CONDITION",
    "Talent": "CONDITION", # Talents are like Boons/Conditions
    "Mystery": "MYSTERY",
    "Mythos": "MYTHOS",
    "Prelude": "ITEM", # Or a separate type, but for now ITEM
    "Personal Story": "INVESTIGATOR", # Specific to investigators
    "Adventure": "ENCOUNTER",
    "Curse": "CONDITION",
    "Debt": "CONDITION",
    "Artifact": "ITEM", # Keep artifact as ITEM for now or update enum if possible
}

INVESTIGATORS = [
    # Base Game & All Expansions (Mountains of Madness, Under the Pyramids, etc.)
    "Leo Anderson", "Akachi Onyele", "Diana Stanley", "Norman Withers",
    "Silas Marsh", "Trish Scarborough", "Charlie Kane", "Lily Chen",
    "Lola Hayes", "Jim Culver", "Jacqueline Fine", "Mark Harrigan",
    "Sister Mary", "Amanda Sharpe", "Calvin Wright", "Daisy Walker",
    "Dexter Drake", "Father Mateo", "Finn Edwards", "George Barnaby",
    "Gloria Goldberg", "Hank Samson", "Harvey Walters", "Jenny Barnes",
    "Joe Diamond", "Kate Winthrop", "Luke Robinson", "Marie Lambeau",
    "Minh Thi Phan", "Monterey Jack", "Patrice Hathaway", "Rex Murphy",
    "Rita Young", "Roland Banks", "Sefina Rousseau", "Skids O'Toole",
    "Tommy Muldoon", "Ursula Downs", "William Yorick", "Zoey Samaras",
    "Agatha Crane", "Agnes Baker", "Ashcan Pete", "Bob Jenkins", 
    "Carson Sinclair", "Daniela Reyes", "Darrell Simmons", "Monterey Jack",
    "Vincent Lee", "Wendy Adams", "Wilson Richards"
]

def sanitize_name(filename):
    name_base = os.path.splitext(filename)[0]
    # Handle double extensions or specific TTS naming
    name_base = re.sub(r'\.webp$', '', name_base, flags=re.I)
    name_base = re.sub(r'\.png$', '', name_base, flags=re.I)
    
    clean_name = re.sub(r'_\d+$', '', name_base).replace('_', ' ').strip()
    
    parts = re.split(r'\s*-\s*|\s*,\s*', clean_name)
    display_name = parts[0].strip()
    tags = [p.strip() for p in parts[1:]]
    
    sub_type = None
    card_type = "ITEM" # Default
    
    # 1. PRIORITY 1: INVESTIGATOR check (High priority to avoid mixup)
    if any(inv.lower() == display_name.lower() or inv.lower() in clean_name.lower() for inv in INVESTIGATORS):
        # Double check it doesn't contain "Research" or "Encounter"
        if "research" not in clean_name.lower() and "encounter" not in clean_name.lower():
             return display_name, "INVESTIGATOR", tags, "INVESTIGATOR"

    # 2. PRIORITY 2: ENCOUNTER check
    encounter_keywords = {
        "Research": "RESEARCH_ENCOUNTER",
        "Encounter": "LOCATION_ENCOUNTER",
        "Other World": "OTHER_WORLD_ENCOUNTER",
        "Expedition": "EXPEDITION_ENCOUNTER",
        "Clue": "RESEARCH_ENCOUNTER",
        "Gate": "OTHER_WORLD_ENCOUNTER"
    }
    
    # Check whole string for encounter indicators
    for k, v in encounter_keywords.items():
        if k.lower() in clean_name.lower():
            sub_type = v
            card_type = "ENCOUNTER"
            return display_name, card_type, tags, sub_type

    # 3. PRIORITY 3: Sub-types in tags (Prioritized by SUB_TYPE_MAPPING order)
    for k, v in SUB_TYPE_MAPPING.items():
        for t in tags:
            if k.lower() in t.lower():
                sub_type = v
                card_type = get_enum_type(v)
                return display_name, card_type, tags, sub_type
        
    for k, v in DIRECT_TYPE_MAPPING.items():
        for t in tags:
            if k.lower() in t.lower():
                return display_name, v, tags, v

    # 4. PRIORITY 4: Check display_name (Prioritized by SUB_TYPE_MAPPING order)
    for k, v in SUB_TYPE_MAPPING.items():
        if k.lower() in display_name.lower():
            sub_type = v
            card_type = get_enum_type(v)
            return display_name, card_type, tags, sub_type

    for k, v in DIRECT_TYPE_MAPPING.items():
        if k.lower() in display_name.lower():
            return display_name, v, tags, v

    # 5. Default Fallback logic: Ensure Every ITEM or ENCOUNTER group has a sub_type
    if card_type == "ITEM" and not sub_type:
        sub_type = "ITEM"
    elif card_type == "ENCOUNTER" and not sub_type:
        sub_type = "LOCATION_ENCOUNTER"
    
    card_type = get_enum_type(sub_type)

    return display_name, card_type, tags, sub_type

def upload_and_seed():
    print(f"Starting full recursive upload and seed from {ASSET_DIR}...")
    
    files_with_relative_paths = []
    for root, _, filenames in os.walk(ASSET_DIR):
        for filename in filenames:
            if filename.lower().endswith(('.webp', '.png')):
                rel_path = os.path.relpath(os.path.join(root, filename), ASSET_DIR)
                files_with_relative_paths.append(rel_path.replace('\\', '/'))

    files = sorted(files_with_relative_paths)
    total = len(files)
    
    # 1. Ensure bucket exists
    try:
        supabase.storage.get_bucket(BUCKET_NAME)
    except:
        supabase.storage.create_bucket(BUCKET_NAME, options={"public": True})

    batch_size = 50
    for i in range(0, total, batch_size):
        batch_files = files[i:i+batch_size]
        print(f"Processing batch {i//batch_size + 1}/{(total + batch_size - 1)//batch_size}...")
        
        for rel_filename in batch_files:
            # Use basename for sanitization but rel_filename for upload/URL
            filename = os.path.basename(rel_filename)
            display_name, card_type, tags, sub_type = sanitize_name(filename)
            image_url = f"{SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{rel_filename}"
            
            # A. Upload file (upsert=true)
            full_path = os.path.join(ASSET_DIR, rel_filename)
            with open(full_path, 'rb') as f:
                try:
                    supabase.storage.from_(BUCKET_NAME).upload(
                        path=rel_filename,
                        file=f,
                        file_options={"cache-control": "3600", "upsert": "true"}
                    )
                except Exception as e:
                    if "already exists" not in str(e).lower():
                        print(f"Error uploading {rel_filename}: {e}")

            if card_type == "MONSTER" or card_type == "ANCIENT_ONE":
                print(f"| {card_type} | {display_name} ({filename})")

            # B. Seed/Upsert Database
            card_data = {
                "game_type": GAME_TYPE,
                "type": card_type,
                "content": display_name,
                "image_url": image_url,
                "metadata": {
                    "tags": tags,
                    "sub_type": sub_type,
                    "original_filename": rel_filename
                }
            }
            
            try:
                # We skip checking for existence because we just cleared the table
                supabase.table("library_cards").insert(card_data).execute()
            except Exception as e:
                print(f"Error seeding {display_name}: {e}")
                import time
                time.sleep(1) # Sleep a bit on error

    print(f"Finished! Total cards processed: {total}")

if __name__ == "__main__":
    upload_and_seed()
