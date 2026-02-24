---
name: project-deception-core
description: "MANDATORY: Core rules for Noir aesthetics, espionnage terminology, and token-saving strategies for the Deception game project. READ THIS FIRST for any task."
---

# Deception Project Core Skill 🌑🕵️‍♂️

This skill provides the internal "compass" for any AI agent working on the Deception: Manager Game project. Following these rules is mandatory to maintain consistency and efficiency.

## 1. The Noir Vibe (MANDATORY Architecture)
- **Aesthetic**: Stick to the Dashboard layout. Use `Colors.white10`, `Colors.grey`, `Colors.redAccent`, and gold/crimson tones.
- **Terminology**:
    - **Room** -> Session / Mission
    - **Player** -> Operative / Agent
    - **Room List** -> Intel Feed
    - **User ID** -> Operative Identity
- **Premium UX**: Always use `flutter_animate` for entry animations. Ensure buttons have hover/splash feedback (see `LobbyScreen._buildLogoutLink`).

## 2. Token-Saving Protocol (Efficiency)
To save tokens and reduce costs, apply these "Signal Point" strategies:

- **Do Not Scavenge**: Before reading the whole directory, read these files ONLY:
    - `backend/src/app/games/deception/logic.py` (The brain of the game)
    - `frontend/lib/providers/game_provider.dart` (The nervous system - WS)
    - `frontend/lib/screens/lobby_screen.dart` (The face of the app)
- **Compressed Logic**: If the user asks about "rules", refer to `logic.py`'s `handle_event` method.
- **State Check**: Always assume `main.py` handles the raw WebSocket lifecycle and `logic.py` handles the game state.

## 3. Critical DB/Socket Rules
- **JWT Mapping**: `client_id` in WebSocket MUST match Supabase `sub` claim.
- **Hard Closure**: When a host leaves, always call `close_game()` in `logic.py` to purge the session from Supabase/Redis. Orphaned rooms are forbidden.
- **Enum Safety**: Always use `.value` when passing Enums to Supabase queries.

## 5. Communication & Serialization (CRITICAL)
- **Explicit Serialization**: Never pass a raw `DeceptionGame` object to `GameUpdateMessage` or return it directly in API responses.
- **Mandatory Pattern**: Always use `game.to_game_state()` when broadcasting or syncing. This ensures the output matches the `GameState` Pydantic schema and prevents `ValidationError` crashes.
