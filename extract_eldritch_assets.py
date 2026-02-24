import json
import os
import re
from PIL import Image, ImageEnhance

# Configuration
JSON_PATH = r"C:\Users\Le Nguyen\Documents\My Games\Tabletop Simulator\Mods\Workshop\2075317062.json"
IMAGES_DIR = r"C:\Users\Le Nguyen\Documents\My Games\Tabletop Simulator\Mods\Images"
OUTPUT_DIR = r"E:\image\eldrich horror"

def sanitize_filename(name):
    # Remove invalid characters for Windows filenames
    return re.sub(r'[\\/*?:"<>|]', "", name).strip()

def get_local_image_path(url):
    # TTS hashes URLs to filenames. 
    # Logic: remove protocol, keep rest, then hash? 
    # Easier: Search the Images directory for the 40-char hash in the URL.
    match = re.search(r'ugc/(\d+)/([A-F0-9]+)/', url)
    if not match:
        return None
    file_hash = match.group(2)
    for f in os.listdir(IMAGES_DIR):
        if file_hash in f:
            return os.path.join(IMAGES_DIR, f)
    return None

def process_custom_model(obj):
    nickname = obj.get("Nickname", "").strip()
    face_url = obj.get("CustomMesh", {}).get("DiffuseURL") or obj.get("image_url")
    
    if not nickname or not face_url:
        return

    img_path = get_local_image_path(face_url)
    if not img_path:
        # print(f"Skipping {nickname}: Local image not found for {face_url}")
        return

    try:
        with Image.open(img_path) as img:
            # Add container as a tag if it exists
            container = obj.get("container", "")
            base_name = sanitize_filename(nickname)
            if container:
                filename = f"{base_name} - {sanitize_filename(container)}.png"
            else:
                filename = f"{base_name}.png"
                
            dest_path = os.path.join(OUTPUT_DIR, filename)
            
            if os.path.exists(dest_path):
                 dest_path = os.path.join(OUTPUT_DIR, f"{sanitize_filename(nickname)}_{obj.get('guid', 'model')}.png")
            
            img.save(dest_path, "PNG")
            print(f"Extracted Model: {nickname} ({container}) -> {os.path.basename(dest_path)}")
    except Exception as e:
        print(f"Error processing model {nickname}: {e}")

def process_card(obj, custom_deck_map):
    nickname = obj.get("Nickname", "").strip()
    card_id = obj.get("CardID")
    
    if not nickname or card_id is None:
        return

    # Decompose CardID: DeckID (ID/100) and CardIndex (ID%100)
    deck_id = str(card_id // 100)
    card_index = card_id % 100
    
    deck_info = custom_deck_map.get(deck_id)
    if not deck_info:
        return

    face_url = deck_info.get("FaceURL")
    num_w = deck_info.get("NumWidth", 10)
    num_h = deck_info.get("NumHeight", 7)
    
    if not face_url:
        return

    img_path = get_local_image_path(face_url)
    if not img_path:
        print(f"Skipping {nickname}: Local image not found for {face_url}")
        return

    try:
        with Image.open(img_path) as img:
            # TTS sheets are organized by grid
            sheet_w, sheet_h = img.size
            card_w = sheet_w / num_w
            card_h = sheet_h / num_h
            
            row = card_index // num_w
            col = card_index % num_w
            
            left = col * card_w
            top = row * card_h
            right = left + card_w
            bottom = top + card_h
            
            crop = img.crop((left, top, right, bottom))
            
            # HD Enhancement: Slight Sharpness and Contrast for "Premium" feel
            enhancer = ImageEnhance.Sharpness(crop)
            crop = enhancer.enhance(1.5)
            enhancer = ImageEnhance.Contrast(crop)
            crop = enhancer.enhance(1.1)
            
            # Save
            filename = sanitize_filename(nickname) + ".png"
            dest_path = os.path.join(OUTPUT_DIR, filename)
            
            # Avoid overwriting if multiple cards have same name (common in EH)
            if os.path.exists(dest_path):
                dest_path = os.path.join(OUTPUT_DIR, f"{sanitize_filename(nickname)}_{card_id}.png")
                
            crop.save(dest_path, "PNG")
            print(f"Extracted: {nickname} -> {os.path.basename(dest_path)}")
            
    except Exception as e:
        print(f"Error processing {nickname}: {e}")

def run_extraction():
    print(f"Scanning {JSON_PATH}...")
    with open(JSON_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # We need to collect all CustomDeck definitions first
    # They can be at top level or nested
    custom_deck_map = {}

    def collect_decks(obj):
        if isinstance(obj, dict):
            if "CustomDeck" in obj:
                custom_deck_map.update(obj["CustomDeck"])
            for val in obj.values():
                collect_decks(val)
        elif isinstance(obj, list):
            for item in obj:
                collect_decks(item)

    collect_decks(data)
    print(f"Detected {len(custom_deck_map)} custom decks.")

    # Now process all Card objects
    processed_count = 0
    
    def process_all_cards(obj, container_name=""):
        nonlocal processed_count
        if isinstance(obj, dict):
            name = obj.get("Name")
            current_nickname = obj.get("Nickname", "")
            # Update container name if this is a bag/deck that has a nickname
            if name in ["Bag", "Deck", "DeckCustom", "Custom_Model_Bag", "Custom_Model_Infinite_Bag"]:
                 container_name = current_nickname or container_name
                 
            if name == "Card" or name == "CardCustom":
                process_card(obj, custom_deck_map)
                processed_count += 1
            elif name == "Custom_Model" or name == "Custom_Token":
                # Ensure we use the passed container_name ifobj doesn't have it
                if not obj.get("container"):
                    obj["container"] = container_name
                process_custom_model(obj)
                processed_count += 1
            
            # Recurse
            if "ContainedObjects" in obj:
                for child in obj["ContainedObjects"]:
                    process_all_cards(child, container_name)
            if "ObjectStates" in obj:
                 for child in obj["ObjectStates"]:
                    process_all_cards(child, container_name)
        elif isinstance(obj, list):
            for item in obj:
                process_all_cards(item, container_name)

    process_all_cards(data)
    print(f"\nExtraction complete. Total cards processed: {processed_count}")

if __name__ == "__main__":
    run_extraction()
