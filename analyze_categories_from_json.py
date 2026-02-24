import json
import os

def analyze_categories(json_path):
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    categories = {}
    
    # 1. Check top-level keys
    for key in data.keys():
        if key == "GUID_Unknown":
            # This is where the main "Bags" live
            bags = data[key]
            for bag in bags:
                nickname = bag.get("nickname")
                guid = bag.get("guid")
                if nickname:
                    # Look for items inside this bag
                    contained = data.get(guid, data.get(nickname, []))
                    categories[nickname] = {
                        "guid": guid,
                        "count": len(contained),
                        "sub_categories": []
                    }
                    
                    # Check if items inside are also containers
                    for item in contained:
                        inner_nickname = item.get("nickname")
                        inner_guid = item.get("guid")
                        inner_name = item.get("name")
                        if inner_name in ["Bag", "Deck", "DeckCustom"]:
                             categories[nickname]["sub_categories"].append(f"{inner_nickname} ({inner_guid})")
        else:
            # Other top level keys might be interesting
            pass

    print(json.dumps(categories, indent=2))

if __name__ == "__main__":
    analyze_categories("backend/tts_card_mappings.json")
