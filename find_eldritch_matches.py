import os

ASSET_DIR = r"E:\image\eldrich horror\new"

def find_matches():
    files = os.listdir(ASSET_DIR)
    
    search_terms = ["Agnes", "Baker", "Azathoth", "Revolver", "Flesh", "Ward", "Leg", "Injury"]
    
    matches = {}
    for term in search_terms:
        matches[term] = [f for f in files if term.lower() in f.lower()]
        
    for term, found in matches.items():
        print(f"--- {term} ---")
        for f in found:
            print(f"  {f}")

if __name__ == "__main__":
    find_matches()
