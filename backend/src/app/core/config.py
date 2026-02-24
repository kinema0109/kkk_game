from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Manager Game"
    API_V1_STR: str = "/api/v1"
    
    # Redis
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: Optional[str] = None
    
    # Supabase
    SUPABASE_URL: Optional[str] = None
    SUPABASE_KEY: Optional[str] = None
    SUPABASE_SERVICE_ROLE_KEY: Optional[str] = None
    SUPABASE_JWT_SECRET: Optional[str] = None
    ADMIN_EMAIL: Optional[str] = None
    
    model_config = SettingsConfigDict(
        env_file=[".env", "../.env"], 
        case_sensitive=True,
        extra="ignore"
    )

settings = Settings()
