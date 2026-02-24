---
name: project-eldritch-core
description: "MANDATORY: Core rules for Eldritch Horror aesthetics, Lovecraftian terminology, and token-saving strategies. READ THIS FIRST for any task."
---

# Eldritch Horror Project Core Skill 🐙🕰️

This skill provides the strategic "compass" for the Eldritch Horror adaptation. Consistency in theme and efficiency in token usage are mandatory.

## 1. The Lovecraftian Vibe (MANDATORY Architecture)
- **Aesthetic**: Use a "parchment and ink" or "forbidden archive" look. Colors: `Colors.brown` (sepia), `Colors.blueGrey` (mist), `Colors.teal.withOpacity(0.1)` (eldritch glow).
- **Terminology**:
    - **Room** -> Expedition / Investigation Session
    - **Player** -> Investigator
    - **Status** -> Global Doom Level / Omen
    - **Tokens** -> Clues, Sanity, Stamina, Eldritch Tokens
- **Premium UX**: Use parchment-style cards and smooth map transitions. `flutter_animate` for "sanity loss" (shaking) or "eldritch events" (pulsing).

## 2. Token-Saving Protocol (Efficiency)
To save tokens and reduce costs, apply these "Signal Point" strategies:

- **Do Not Scavenge**: Before reading the whole directory, focus on:
    - `backend/src/app/games/eldritch_horror/logic.py` (The state machine)
    - `backend/src/app/games/eldritch_horror/models.py` (The data structure)
    - `frontend/lib/providers/game_provider.dart` (The connection)
- **Compressed Logic**: If the user asks about "rules", refer to the `MythosPhase`, `ActionPhase`, and `EncounterPhase` abstractions in the code.

## 3. Eldritch Logic Rules
- **Doom Sync**: The `doom_track` must be strictly synchronized across all investigators.
- **Mystery Logic**: Winning is only possible by solving 3 `Mystery` cards. The backend must validate the completion of each step.
- **Double-Sided Conditions**: Ensure the frontend handles the "flip" of Condition cards (e.g., Debt, Cursed) without exposing the back until triggered.

## 4. Communication & Serialization
- **Standard Pattern**: Always use `game.to_game_state()` to ensure Pydantic/Dart model alignment.
- **Rich State**: The broadcast state should include `active_omen`, `doom_track`, and `active_expedition_location`.
