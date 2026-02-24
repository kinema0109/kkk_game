import json

def analyze():
    with open('tts_card_mappings.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for container, cards in data.items():
        if len(cards) > 0:
            print(f"{container}: {len(cards)} cards")
            # Print first 3 cards as sample
            for card in cards[:3]:
                print(f"  - {card['nickname']}")

if __name__ == "__main__":
    analyze()
