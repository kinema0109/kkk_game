# Project Blueprint

## Project Name: Manager Game
A web-based adaptation of "Deception: Murder in Hong Kong".

## Tech Stack (Updated)
- **Backend**: Python (FastAPI) with WebSockets.
- **State Management**: Redis (Realtime Game State).
- **Database/Auth**: Supabase / PostgreSQL.

- **Architectural Patterns**:
    - **WebSocket Core**: Bidirectional communication for heavy realtime game events.
    - **Redis State**: Ephemeral game state stored in Redis for speed and persistence.
    - **Pro Project Structure**: `src/app` layout (api, core, schemas, services).
    - **Type Safety**: Pydantic v2 and mandatory type hints.

## Guidelines for AI
- Always follow the existing project structure.
- use enums instead of string literals.
- Ensure all API calls are authenticated using Supabase session.
