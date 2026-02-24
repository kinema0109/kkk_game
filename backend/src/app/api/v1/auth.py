from fastapi import APIRouter, Depends, HTTPException
from src.app.core.auth import get_current_user
from src.app.core.i18n import get_translator, Translator
from src.app.core.database import get_supabase
from src.app.api.schemas import RegisterRequest, LoginRequest, AuthResponse

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/register", response_model=AuthResponse, summary="Register a new user")
async def register(req: RegisterRequest, t: Translator = Depends(get_translator)):
    """Registers a new user with email and password, creating a profile."""
    supabase = get_supabase()
    
    # 1. Sign up user via Supabase Auth
    try:
        response = supabase.auth.sign_up({
            "email": req.email,
            "password": req.password,
            "options": {
                "data": {
                    "display_name": req.display_name
                }
            }
        })
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    if not response.user:
        raise HTTPException(status_code=400, detail="Registration failed.")
        
    # 2. Create profile entry (Supabase triggers usually do this, but we do it explicitly if needed)
    # Most Supabase configs handle this via a trigger on auth.users.
    # We check if it exists or create it.
    profile_data = {
        "id": response.user.id,
        "email": req.email,
        "display_name": req.display_name
    }
    supabase.table("profiles").upsert(profile_data).execute()
    
    return AuthResponse(
        user_id=response.user.id,
        email=response.user.email,
        access_token=response.session.access_token if response.session else "",
        refresh_token=response.session.refresh_token if response.session else "",
        message="Registration successful. Please check your email for confirmation if required."
    )

@router.post("/login", response_model=AuthResponse, summary="Login")
async def login(req: LoginRequest, t: Translator = Depends(get_translator)):
    """Authenticate user and return session tokens."""
    supabase = get_supabase()
    
    try:
        response = supabase.auth.sign_in_with_password({
            "email": req.email,
            "password": req.password
        })
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid email or password.")
        
    if not response.session:
        raise HTTPException(status_code=401, detail="Login failed.")
        
    return AuthResponse(
        user_id=response.user.id,
        email=response.user.email,
        access_token=response.session.access_token,
        refresh_token=response.session.refresh_token,
        message="Login successful."
    )

@router.post("/logout", summary="Logout")
async def logout(current_user: dict = Depends(get_current_user)):
    """Signs out the current user."""
    supabase = get_supabase()
    supabase.auth.sign_out()
    return {"message": "Logged out successfully"}

@router.get("/me", summary="Get current user info")
async def get_me(current_user: dict = Depends(get_current_user), t: Translator = Depends(get_translator)):
    """Returns information about the currently authenticated user."""
    return current_user
