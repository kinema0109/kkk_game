import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load .env from backend folder specifically
load_dotenv('.env')

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
ASSET_DIR = r"E:\image\eldrich horror\new"
BUCKET_NAME = "eldritch-assets"

# Keywords for "Must-Have" images
MUST_HAVE_KEYWORDS = ["investigator", "ancient", "monster", "omen", "doom", "prologue", "mystery", "character", "portrait"]

def upload_essential_assets():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # 1. Ensure bucket exists
    try:
        supabase.storage.create_bucket(BUCKET_NAME, options={"public": True})
        print(f"Bucket '{BUCKET_NAME}' created.")
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"Bucket '{BUCKET_NAME}' already exists.")
        else:
            print(f"Error creating bucket: {e}")

    # 2. Filter and Upload
    files = [f for f in os.listdir(ASSET_DIR) if f.lower().endswith('.webp')]
    uploaded_count = 0
    
    for filename in files:
        low_f = filename.lower()
        if any(k in low_f for k in MUST_HAVE_KEYWORDS):
            file_path = os.path.join(ASSET_DIR, filename)
            
            with open(file_path, 'rb') as f:
                try:
                    # Search if file already exists to avoid redundant uploads
                    print(f"Uploading {filename}...")
                    supabase.storage.from_(BUCKET_NAME).upload(
                        path=filename,
                        file=f,
                        file_options={"cache-control": "3600", "upsert": "true"}
                    )
                    uploaded_count += 1
                except Exception as e:
                    print(f"Error uploading {filename}: {e}")
                    
    print(f"Total essential assets uploaded: {uploaded_count}")

if __name__ == "__main__":
    upload_essential_assets()
