# Manager Game Backend

Professional FastAPI backend for the "Deception: Murder in Hong Kong" adaptation.

## Tech Stack
- **FastAPI**: Modern, fast web framework.
- **WebSockets**: Realtime bidirectional communication.
- **Redis**: Fast state management.
- **Pydantic v2**: Data validation and settings.
A high-performance FastAPI backend managed with `uv`, designed for multi-game support and deployment via Docker on Render.

## Technology Stack
- **Framework**: FastAPI (Async-first)
- **Package Manager**: [uv](https://astral.sh/uv) (Extremely fast Python orchestrator)
- **Database**: Supabase (Postgres + Realtime)
- **Infrastructure**: Docker / Render

## Getting Started

### Local Development with `uv`
1. Install `uv`: `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"`
2. Sync dependencies: `uv sync`
3. Run locally: `uv run uvicorn src.app.main:app --reload`

### Running with Docker
1. Build image: `docker build -t manager-game-be .`
2. Run container: `docker run -p 8000:8000 manager-game-be`

## Multi-game Architecture
The backend is designed to handle multiple game types (starting with Deception).
- `src/app/core/base_game.py`: Generic Room/Player logic.
- `src/app/games/[game_name]`: Game-specific implementations.

## Structure
- `src/app/api`: API routes and WebSocket logic.
- `src/app/core`: Configuration and security.
- `tests`: Unit and integration tests.
