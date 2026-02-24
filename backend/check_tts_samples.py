import json

def analyze():
    with open('tts_card_mappings.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    types = {
        'Ancient Ones': data.get('Ancient Ones', []),
        'Monsters': data.get('Monsters', []) + data.get('Epic Monsters', []),
        'Investigators': data.get('Investigators', [])
    }
    
    for t_name, cards in types.items():
        print(f"\n{t_name}: {len(cards)} items")
        for c in cards[:5]:
            nick = c.get('nickname') or "NO NICKNAME"
            url = c.get('image_url') or "NO URL"
            print(f"  - {nick} | {url[:60]}...")

if __name__ == "__main__":
    analyze()
