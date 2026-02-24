import os
import psycopg2
from dotenv import load_dotenv

# Run from backend directory
load_dotenv('.env')

DB_URL = os.getenv("DATABASE_URL")

def apply_migration(file_path):
    print(f"Applying migration: {file_path}")
    with open(file_path, 'r') as f:
        sql = f.read()
    
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = True
    cur = conn.cursor()
    try:
        cur.execute(sql)
        print("Migration applied successfully.")
    except Exception as e:
        print(f"Error applying migration: {e}")
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        apply_migration(sys.argv[1])
    else:
        print("Please provide a migration file path.")
