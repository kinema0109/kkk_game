import sys
from loguru import logger

def setup_logging():
    # Remove default handler
    logger.remove()
    
    # Add custom handler with formatting
    logger.add(
        sys.stdout,
        format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level="DEBUG",
        enqueue=True
    )
    
    # Optional: Log to file with rotation for production debugging
    # Log to file for debugging
    logger.add("logs/app.log", rotation="500 MB", retention="10 days", compression="zip", level="DEBUG")

setup_logging()
