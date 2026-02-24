from fastapi import Request, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from typing import List
from .config import settings
from .logger import logger
from .i18n import get_translator, Translator

import httpx
import time
from threading import Lock

security = HTTPBearer()

class JWKSClient:
    def __init__(self, jwks_url: str, apikey: str = None):
        self.jwks_url = jwks_url
        self.apikey = apikey
        self.keys = []
        self.last_fetch = 0
        self.cache_ttl = 3600  # 1 hour
        self._lock = Lock()

    def get_jwks(self):
        now = time.time()
        with self._lock:
            if not self.keys or (now - self.last_fetch) > self.cache_ttl:
                try:
                    logger.info(f"Fetching JWKS from {self.jwks_url}")
                    headers = {}
                    if self.apikey:
                        headers["apikey"] = self.apikey
                    
                    resp = httpx.get(self.jwks_url, headers=headers, timeout=10)
                    resp.raise_for_status()
                    self.keys = resp.json().get("keys", [])
                    self.last_fetch = now
                    logger.info(f"Successfully fetched {len(self.keys)} keys from JWKS.")
                except Exception as e:
                    logger.error(f"Failed to fetch JWKS: {e}")
            return self.keys

    def get_key(self, kid: str):
        keys = self.get_jwks()
        for k in keys:
            if k.get("kid") == kid:
                return k
        return None

# Global JWKS Client
jwks_client = None
if settings.SUPABASE_URL and settings.SUPABASE_KEY:
    # Supabase JWKS is typically at /auth/v1/.well-known/jwks.json and requires apikey
    jwks_url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/.well-known/jwks.json"
    jwks_client = JWKSClient(jwks_url, apikey=settings.SUPABASE_KEY)

def verify_supabase_jwt(token: str) -> dict:
    """
    Core logic to verify a Supabase JWT.
    Supports both legacy HS256 (symmetric) and new ES256 (JWKS/asymmetric).
    """
    if not settings.SUPABASE_JWT_SECRET:
        logger.warning("SUPABASE_JWT_SECRET is not set. Auth verification will fail.")
        raise ValueError("Authentication secret not configured.")

    # Handle common Swagger/Manual error: double "Bearer " prefix
    if token.startswith("Bearer "):
        token = token.replace("Bearer ", "", 1)
        logger.debug("Automatic cleanup: Removed double 'Bearer ' prefix from token.")

    # 1. Peek at the header to check the algorithm and kid
    try:
        header = jwt.get_unverified_header(token)
        alg = header.get("alg")
        kid = header.get("kid")
        logger.debug(f"JWT Header: {header}")
    except Exception as e:
        logger.error(f"Could not parse JWT Header: {e}. Token start: {token[:10]}...")
        raise ValueError("Invalid token format (header parse failed).")

    # 2. Determine verification key based on algorithm
    if alg == "ES256":
        if not jwks_client:
            raise ValueError("JWKS Client not initialized.")
        
        jwk = jwks_client.get_key(kid)
        if not jwk:
            logger.error(f"Key ID {kid} not found in JWKS.")
            raise ValueError(f"Key ID {kid} not found. Algorithm mismatch or rotated keys.")
        verification_key = jwk
        algorithms = ["ES256"]
    else:
        # Fallback to HS256 (symmetric secret)
        import base64
        secret = settings.SUPABASE_JWT_SECRET
        try:
            missing_padding = len(secret) % 4
            if missing_padding:
                secret += "=" * (4 - missing_padding)
            verification_key = base64.b64decode(secret)
        except Exception:
            verification_key = settings.SUPABASE_JWT_SECRET
        algorithms = ["HS256", "HS384", "HS512"]

    # 3. Decode token
    payload = jwt.decode(
        token, 
        verification_key, 
        algorithms=algorithms, 
        options={"verify_aud": False}
    )
    user_id: str = payload.get("sub")
    if user_id is None:
        raise ValueError("Invalid authentication credentials (missing sub).")
    
    return {
        "id": user_id, 
        "email": payload.get("email"),
        "role": payload.get("role")
    }

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    FastAPI Dependency to verify JWT from Supabase.
    """
    try:
        return verify_supabase_jwt(credentials.credentials)
    except ValueError as e:
        # Map ValueError to HTTPException for FastAPI
        status_code = status.HTTP_401_UNAUTHORIZED
        if "not configured" in str(e) or "not initialized" in str(e):
             status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
             
        raise HTTPException(
            status_code=status_code,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"} if status_code == 401 else None,
        )
    except JWTError as e:
        logger.error(f"JWT Decode error: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Could not validate credentials: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )

class RoleChecker:
    """
    A class-based dependency for checking user roles.
    Example: Depends(RoleChecker(["admin", "moderator"]))
    """
    def __init__(self, allowed_roles: List[str]):
        self.allowed_roles = allowed_roles

    async def __call__(self, request: Request, current_user: dict = Depends(get_current_user)):
        # 1. Check JWT role
        user_role = current_user.get("role")
        if user_role in self.allowed_roles:
            return current_user
            
        # 2. Check Database for extra security (especially for admin)
        if "admin" in self.allowed_roles:
            from .database import get_supabase
            supabase = get_supabase()
            if supabase:
                res = supabase.table("profiles").select("is_admin").eq("id", current_user["id"]).execute()
                if res and res.data and len(res.data) > 0 and res.data[0].get("is_admin"):
                    return current_user
                    
            # 3. Check legacy ADMIN_EMAIL fallback
            if current_user.get("email") == settings.ADMIN_EMAIL:
                return current_user

        # Localized error message
        t: Translator = await get_translator(request)
        detail = t.t("admin.required", default=f"Quyền {', '.join(self.allowed_roles)} là bắt buộc.")
        
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail
        )

# Predefined dependencies for convenience
admin_only = RoleChecker(["admin"])
