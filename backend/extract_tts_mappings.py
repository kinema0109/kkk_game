import json
import os

JSON_PATH = r"c:\Users\Le Nguyen\Documents\My Games\Tabletop Simulator\Mods\Workshop\2075317062.json"

def process_object(obj, container_name="Root"):
    results = []
    nickname = obj.get("Nickname", "")
    name = obj.get("Name", "")
    
    # If it's a card, tile, or model
    image_url = ""
    if name in ["Card", "CardCustom"]:
        card_id = obj.get("CardID")
        custom_deck = obj.get("CustomDeck", {})
        deck_id = str(card_id // 100) if card_id else None
        if deck_id and deck_id in custom_deck:
            image_url = custom_deck[deck_id].get("FaceURL", "")
    elif name == "Custom_Tile":
        image_url = obj.get("CustomImage", {}).get("ImageURL", "")
    elif name == "Custom_Model":
        image_url = obj.get("CustomMesh", {}).get("DiffuseURL", "")
        
    if image_url or nickname:
        description = obj.get("Description", "")
        gm_notes = obj.get("GMNotes", "")
        
        results.append({
            "nickname": nickname,
            "description": description,
            "gm_notes": gm_notes,
            "container": container_name,
            "image_url": image_url,
            "name": name,
            "guid": obj.get("GUID")
        })
    
    # Recursive search in children
    for key in ["ContainedObjects", "ObjectStates"]:
        if key in obj and isinstance(obj[key], list):
            # If this is a deck or bag, use its nickname or GUID
            obj_nickname = obj.get("Nickname", "")
            obj_guid = obj.get("GUID", "Unknown")
            child_container = obj_nickname if obj_nickname else f"GUID_{obj_guid}"
            
            for child in obj[key]:
                results.extend(process_object(child, child_container))
                
    return results

def main():
    if not os.path.exists(JSON_PATH):
        print(f"File not found: {JSON_PATH}")
        return

    with open(JSON_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    all_cards = process_object(data)
    
    # Filter and group
    summary = {}
    for card in all_cards:
        c = card["container"]
        if c not in summary:
            summary[c] = []
        summary[c].append(card)

    # Print summary of containers
    print("Found Containers:")
    for c in sorted(summary.keys()):
        print(f"- {c} ({len(summary[c])} cards)")

    # Save detailed mapping
    with open("tts_card_mappings.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
    
    print("\nDetailed mapping saved to tts_card_mappings.json")

if __name__ == "__main__":
    main()
