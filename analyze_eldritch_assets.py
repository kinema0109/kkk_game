import os

ASSET_DIR = r"E:\image\eldrich horror\new"

# Keywords for essential art
ESSENTIAL_KEYWORDS = ["investigator", "character", "portrait", "ancient", "monster", "omen", "doom", "prologue", "mystery"]

# Keywords for text-replaceable cards
DYNAMIC_KEYWORDS = ["item", "weapon", "trinket", "artifact", "spell", "ritual", "incantation", "glamour", "condition", "illness", "injury", "boon", "curse", "encounter", "debt", "talent"]

def analyze_assets():
    files = [f for f in os.listdir(ASSET_DIR) if f.lower().endswith('.webp')]
    
    essential = []
    dynamic = []
    unknown = []
    
    for f in files:
        low_f = f.lower()
        is_essential = any(k in low_f for k in ESSENTIAL_KEYWORDS)
        is_dynamic = any(k in low_f for k in DYNAMIC_KEYWORDS)
        
        if is_essential:
            essential.append(f)
        elif is_dynamic:
            dynamic.append(f)
        else:
            unknown.append(f)
            
    print(f"Total files: {len(files)}")
    print(f"Essential: {len(essential)}")
    print(f"Dynamic (Replaceable): {len(dynamic)}")
    print(f"Unknown: {len(unknown)}")
    
    print("\nSample Unknown:")
    for f in unknown[:20]:
        print(f" - {f}")

if __name__ == "__main__":
    analyze_assets()
