# Manager Game Hub: Multi-Mission Platform 🏛️🎮

A premium, modular multi-game engine for digital board game adaptations. Host, join, and manage diverse game sessions from a single unified ecosystem.

## ✨ Key Features
- **Global Operation Hub**: A worldwide map UI for tracking investigator movement and eldritch activities.
- **Ancient One Management**: Dedicated state tracking for Azathoth, Cthulhu, and others.
- **Dynamic Encounter Engine**: System for handling Research, Expedition, and Other World encounters.
- **Mystery Resolver**: Logic for tracking and solving the 3 mysteries required for victory.
- **Arkham-Grade UI**: Premium thematic design with Lovecraftian aesthetics and dynamic omen tracking.

---

## 🛠 Tech Stack
-   **Frontend**: Flutter (Dart) + `flutter_animate` + `supabase_flutter`.
-   **Backend**: FastAPI (Python) + `pydantic` + `structlog`.
-   **Infrastructure**: Redis (Real-time state) + Supabase (Persistence & Auth).

---

## 🚀 Quick Start - Backend
The backend manages real-time state transitions and data persistence.

### Option A: Local Development
Ensure you have Redis and UV installed.
```bash
cd backend
uv sync
uv run uvicorn src.app.main:app --reload
```

### Option B: Docker (Recommended)
```bash
docker-compose up -d --build
```

---

## 📱 Quick Start - Frontend
```bash
cd frontend
flutter pub get
flutter run
```

---

## 🌑 Vibe Coding & AI Efficiency
This project is optimized for "Vibe Coding" (intent-based development). To save tokens and improve AI throughput:
- **Compressed Context**: Refer the AI to [.vibe_coding_guide.md](.vibe_coding_guide.md) at the start of any task.
- **Signal Points**: Focus AI attention on `logic.py` (state) and `game_provider.dart` (connection) to avoid full-code scans.

---

## 🔑 Deployment & Admin
- **Render**: Deploy using the `backend` root directory to trigger builds only on backend changes.
- **Admin**: Use the `migrate_admin.py` script to escalate operative privileges.
```bash
docker-compose exec backend uv run src/app/scripts/migrate_admin.py
```
