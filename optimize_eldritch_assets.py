import os
import PIL
from PIL import Image

# Configuration
SOURCE_DIR = r"E:\image\eldrich horror"
TARGET_DIR = r"E:\image\eldrich horror\new"
QUALITY = 75
MAX_WIDTH = 1024  # For large sheets like Ancient Ones

# Essential categories (using keywords for now)
ESSENTIAL_KEYWORDS = [
    "Investigator", "Ancient One", "Monster", "Art", "Character", "Portrait", 
    "Azathoth", "Cthulhu", "Shub-Niggurath", "Yog-Sothoth"
]

def is_essential(filename):
    # If the project is early, we might want to keep more for now, 
    # but let's filter based on the optimization strategy.
    # For simplicity in this script, we'll convert everything but 
    # the user might want a more refined filter later.
    return True 

def optimize_assets():
    if not os.path.exists(TARGET_DIR):
        os.makedirs(TARGET_DIR)

    files = [f for f in os.listdir(SOURCE_DIR) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
    total = len(files)
    count = 0
    saved_size = 0

    print(f"Starting optimization of {total} files...")

    for filename in files:
        source_path = os.path.join(SOURCE_DIR, filename)
        target_filename = os.path.splitext(filename)[0] + ".webp"
        target_path = os.path.join(TARGET_DIR, target_filename)

        try:
            with Image.open(source_path) as img:
                orig_size = os.path.getsize(source_path)
                
                # Resize if too large (e.g. Ancient One sheets)
                if img.width > MAX_WIDTH:
                    w_percent = (MAX_WIDTH / float(img.width))
                    h_size = int((float(img.height) * float(w_percent)))
                    img = img.resize((MAX_WIDTH, h_size), Image.Resampling.LANCZOS)
                
                # Convert to RGB if necessary (WebP supports RGBA but sometimes RGB is smaller)
                # Keep alpha for cards
                img.save(target_path, "WEBP", quality=QUALITY, method=6)
                
                new_size = os.path.getsize(target_path)
                saved_size += (orig_size - new_size)
                count += 1
                
                if count % 100 == 0:
                    print(f"Processed {count}/{total}...")
                    
        except Exception as e:
            print(f"Error processing {filename}: {e}")

    print(f"\nOptimization Complete!")
    print(f"Total files processed: {count}")
    print(f"Total space saved: {saved_size / (1024 * 1024):.2f} MB")
    print(f"Target directory: {TARGET_DIR}")

if __name__ == "__main__":
    optimize_assets()
