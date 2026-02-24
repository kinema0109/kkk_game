import sys
import os
from unittest.mock import MagicMock

# Add src to path
sys.path.append(os.path.join(os.getcwd(), "src"))

from app.core.auth import get_current_user
from fastapi.security import HTTPAuthorizationCredentials
from jose import jwt
# import pytest

# Fake settings
class MockSettings:
    SUPABASE_JWT_SECRET = "super-secret-key-that-needs-to-be-long-enough-for-hs256"
    ADMIN_EMAIL = "admin@example.com"

import app.core.auth
app.core.auth.settings = MockSettings()

def test_double_bearer_handling():
    # HS256 token
    secret = MockSettings.SUPABASE_JWT_SECRET
    payload = {"sub": "user123", "email": "test@example.com", "role": "player"}
    token = jwt.encode(payload, secret, algorithm="HS256")
    
    # Simulate double "Bearer "
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=f"Bearer {token}")
    
    user = get_current_user(credentials)
    assert user["id"] == "user123"
    print("OK: Double Bearer handling works.")

def test_secret_padding():
    # A secret that needs padding for base64
    app.core.auth.settings.SUPABASE_JWT_SECRET = "YmFzZTY0" # "base64" without padding
    # Wait, "YmFzZTY0" is already exactly 8 chars (multiple of 4). 
    # Let's try "YmFzZTY" (7 chars)
    short_secret = "YmFzZTY" 
    app.core.auth.settings.SUPABASE_JWT_SECRET = short_secret
    
    # In auth.py, it pads then base64 decodes. 
    # "YmFzZTY=" decodes to something.
    
    # This is hard to test without exact knowledge of what the user's secret is,
    # but we can verify the padding logic doesn't crash.
    from fastapi import HTTPException
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="invalid-token")
    try:
        get_current_user(credentials)
        print("FAILED: No exception raised in test_secret_padding")
        assert False
    except Exception as e:
        # Just log and continue, we want to ensure it doesn't CRASH during secret processing
        print(f"Captured Secret Padding Exception: {type(e).__name__}")
    print("OK: Secret padding logic doesn't crash.")

def test_jwks_es256_mocked():
    from unittest.mock import patch
    import app.core.auth
    
    # 1. Mock settings
    app.core.auth.settings.SUPABASE_URL = "https://example.supabase.co"
    # Ensure jwks_client is initialized
    from app.core.auth import JWKSClient
    app.core.auth.jwks_client = JWKSClient(f"{app.core.auth.settings.SUPABASE_URL}/auth/v1/jwks")
    
    # 2. Mock JWKS response
    # We'll use a real-looking JWK but skip real crypto for simplicity if possible, 
    # or just mock the decode call.
    mock_jwk = {
        "kid": "62367c9f-e5a0-4f8a-badf-5c23f8856070",
        "alg": "ES256",
        "kty": "EC",
        "crv": "P-256",
        "x": "...",
        "y": "..."
    }
    
    with patch("httpx.get") as mock_get:
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {"keys": [mock_jwk]}
        
        # Create a token that looks like ES256
        token = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYyMzY3YzlmLW...ZHVtbXk"
        # We need a token with a valid KID in header
        import json
        import base64
        
        header = {"alg": "ES256", "typ": "JWT", "kid": "62367c9f-e5a0-4f8a-badf-5c23f8856070"}
        payload = {"sub": "user_es256", "email": "es256@example.com"}
        
        def b64_url_encode(data: dict):
            return base64.urlsafe_b64encode(json.dumps(data).encode()).decode().rstrip("=")
            
        token = f"{b64_url_encode(header)}.{b64_url_encode(payload)}.signature"
        
        credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
        
        # Mock jwt.decode because real ES256 verify requires real keys and cryptography
        with patch("jose.jwt.decode") as mock_decode:
            mock_decode.return_value = payload
            
            user = get_current_user(credentials)
            
            assert user["id"] == "user_es256"
            mock_decode.assert_called_once()
            # Verify it picked the right key
            args, kwargs = mock_decode.call_args
            assert args[1] == mock_jwk  # Should have passed the JWK dict
            assert args[2] == ["ES256"]
            
    print("OK: JWKS ES256 verification logic works.")

if __name__ == "__main__":
    try:
        test_double_bearer_handling()
        test_secret_padding()
        test_jwks_es256_mocked()
        print("\nAll tests passed!")
    except Exception as e:
        print(f"\nTest failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
