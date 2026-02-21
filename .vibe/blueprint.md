# Project Blueprint

## Project Name: Manager Game
A web-based adaptation of "Deception: Murder in Hong Kong", evolved into a multi-game engine.

## Tech Stack (Updated)
- **Backend**: Python (FastAPI) with WebSockets.
- **State Management**: Redis (Hybrid state: active games in Redis, permanent records in Supabase).
- **Database/Auth**: Supabase / PostgreSQL.
- **Dependency Management**: `uv`.
- **Infrastructure**: Docker / Render (CI/CD via GitHub Actions).

## Architectural Patterns
- **Multi-game Core**: Generic `BaseRoom` and `BasePlayer` classes for different game modules.
- **Deception Module**: Ported from an existing Next.js backend (`/myproject/deception`).
- **WebSocket Core**: Bidirectional communication for heavy realtime game events.
- **Type Safety**: Pydantic v2 and mandatory type hints.

## Guidelines for AI
- Always follow the existing project structure.
- Use enums instead of string literals.
- Ensure all API calls/WebSocket events are compatible with the Supabase schema.
- Porting logic from Next.js (TypeScript) to FastAPI (Python) must preserve game rules.
