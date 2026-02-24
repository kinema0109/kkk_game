import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load env from backend folder
load_dotenv(dotenv_path='./backend/.env')

url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY") # Use service role for bypass RLS if needed
supabase: Client = create_client(url, key)

SOURCE_DIR = r"E:\image\eldrich horror\new"
BUCKET_NAME = "eldritch-assets"

def ensure_bucket_exists():
    try:
        supabase.storage.get_bucket(BUCKET_NAME)
        print(f"Bucket {BUCKET_NAME} already exists.")
    except Exception:
        print(f"Bucket {BUCKET_NAME} not found. Creating it...")
        supabase.storage.create_bucket(BUCKET_NAME, options={"public": True})

def upload_assets():
    ensure_bucket_exists()
    files = [f for f in os.listdir(SOURCE_DIR) if f.lower().endswith('.webp')]
    total = len(files)
    count = 0
    
    print(f"Starting upload of {total} assets to {BUCKET_NAME}...")

    for filename in files:
        file_path = os.path.join(SOURCE_DIR, filename)
        
        # In Supabase Storage, we use the filename as the storage path
        # We can also organize into folders if needed, e.g. "cards/filename"
        storage_path = filename 

        try:
            with open(file_path, 'rb') as f:
                # Upload with upsert=True to allow retries
                res = supabase.storage.from_(BUCKET_NAME).upload(
                    path=storage_path,
                    file=f,
                    file_options={"cache-control": "3600", "upsert": "true", "content-type": "image/webp"}
                )
                count += 1
                if count % 50 == 0:
                    print(f"Uploaded {count}/{total}...")
        except Exception as e:
            print(f"Error uploading {filename}: {e}")

    print(f"\nUpload complete! Total assets uploaded: {count}")

if __name__ == "__main__":
    upload_assets()
