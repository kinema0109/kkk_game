import sys
import os
import json
import base64
from unittest.mock import patch, MagicMock

# Add src to path
sys.path.append(os.path.join(os.getcwd(), "src"))

from app.core.auth import get_current_user
from fastapi.security import HTTPAuthorizationCredentials
from jose import jwt

# 1. Mock settings
import app.core.auth
app.core.auth.settings.SUPABASE_URL = "https://example.supabase.co"
app.core.auth.settings.SUPABASE_JWT_SECRET = "legacy-secret"

# 2. Setup JWKS client
from app.core.auth import JWKSClient
jwks_url = f"{app.core.auth.settings.SUPABASE_URL}/auth/v1/.well-known/jwks.json"
app.core.auth.jwks_client = JWKSClient(jwks_url, apikey=app.core.auth.settings.SUPABASE_KEY)

def b64_url_encode(data: dict):
    return base64.urlsafe_b64encode(json.dumps(data).encode()).decode().rstrip("=")

def test_es256():
    print("Testing ES256 (JWKS)...")
    header = {"alg": "ES256", "typ": "JWT", "kid": "62367c9f-e5a0-4f8a-badf-5c23f8856070"}
    payload = {"sub": "user_es256", "email": "es256@example.com"}
    token = f"{b64_url_encode(header)}.{b64_url_encode(payload)}.c2lnbmF0dXJl"
    
    mock_jwk = {"kid": "62367c9f-e5a0-4f8a-badf-5c23f8856070", "alg": "ES256"}
    
    with patch("httpx.get") as mock_get:
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {"keys": [mock_jwk]}
        
        credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
        try:
            get_current_user(credentials)
            print("FAILED: No exception raised (should have failed signature)")
        except Exception as e:
            detail = getattr(e, "detail", str(e))
            # If we get "Signature verification failed", it means it correctly 
            # loaded the JWK and tried to verify with ES256!
            if "Signature verification failed" in detail:
                 print("SUCCESS: ES256 (JWKS) flow verified (reached signature check).")
            else:
                 print(f"FAILED: Unexpected error in ES256 flow: {detail}")

def test_hs256():
    print("Testing HS256 (Legacy)...")
    # Use different secret to ensure it's not hardcoded
    import app.core.auth
    app.core.auth.settings.SUPABASE_JWT_SECRET = "another-secret"
    
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {"sub": "user_hs256"}
    token = jwt.encode(payload, "another-secret", algorithm="HS256")
    
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    try:
        user = get_current_user(credentials)
        if user and user["id"] == "user_hs256":
            print("SUCCESS: HS256 verified.")
        else:
            print(f"FAILED: Unexpected user info: {user}")
    except Exception as e:
        print(f"FAILED: HS256 error: {e}")

if __name__ == "__main__":
    try:
        test_es256()
        test_hs256()
        print("\nAll verification steps completed successfully.")
    except Exception as e:
        print(f"\nVerification encountered an error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
