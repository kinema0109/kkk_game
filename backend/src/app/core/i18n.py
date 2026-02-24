import json
import os
from typing import Dict, Any, Optional
from fastapi import Request, Depends
from pathlib import Path

class Translator:
    """
    A simple JSON-based translator for FastAPI.
    """
    def __init__(self, locale: str = "en", translations: Dict[str, Any] = None):
        self.locale = locale
        self.translations = translations or {}

    def t(self, key: str, default: Optional[str] = None) -> str:
        """
        Translates a key into the current locale.
        Supports nested keys using dot notation (e.g., "errors.not_found").
        """
        keys = key.split(".")
        value = self.translations
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
            else:
                value = None
                break
        
        return str(value) if value is not None else (default or key)

# Global cache for translations to avoid re-reading files on every request
_translations_cache: Dict[str, Dict[str, Any]] = {}

def load_translations(locales_dir: Path):
    global _translations_cache
    if not locales_dir.exists():
        return

    for file in locales_dir.glob("*.json"):
        lang = file.stem
        try:
            with open(file, "r", encoding="utf-8") as f:
                _translations_cache[lang] = json.load(f)
        except Exception as e:
            print(f"Failed to load translation file {file}: {e}")

async def get_translator(request: Request) -> Translator:
    """
    Dependency to get the translator instance based on Accept-Language header.
    """
    # 1. Get language from header (e.g., "vi,en-US;q=0.9,en;q=0.8")
    accept_lang = request.headers.get("Accept-Language", "en")
    primary_lang = accept_lang.split(",")[0].split("-")[0].lower()
    
    # 2. Fallback to English if not supported
    if primary_lang not in _translations_cache:
        primary_lang = "en"
        
    return Translator(
        locale=primary_lang,
        translations=_translations_cache.get(primary_lang, {})
    )

# Initialize on module load
LOCALES_DIR = Path(__file__).parent.parent / "locales"
load_translations(LOCALES_DIR)
