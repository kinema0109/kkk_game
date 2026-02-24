# Project Blueprint: Manager Game Hub 🏛️🎮

## Project Name: Manager Game Engine
A modular multi-game platform designed to host various digital board game adaptations.

### Supported Games (Alpha Phase)
1. **Deception: Murder in Hong Kong** (Noir Espionage)
2. **Eldritch Horror** (Global Lovecraftian Strategy)

## Tech Stack
- **Backend**: Python (FastAPI) + WebSockets.
- **State Management**: Redis (Active game state) + Supabase (Persistence).
- **Frontend**: Flutter (Mobile/Web) + `flutter_animate`.

## Architectural Patterns
- **Turn-Based Phases**: Strict enforcement of Action, Encounter, and Mythos phases.
- **Global Map Engine**: Coordinate-based movement and location-specific encounter triggers.
- **Card-Driven Logic**: Dynamic deck management (Mythos, Research, Expedition, Mystery).
- **Stat-Check System**: Automated die rolling and modifier calculations for investigator stats.

## Guidelines for AI
- Use the `project-eldritch-core` skill for all tasks.
- Prioritize `eldritch_horror/logic.py` as the source of truth for game rules.
- Maintain "forbidden archive" aesthetics (sepia tones, parchment textures).
