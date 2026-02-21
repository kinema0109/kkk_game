# Deception: Manager Game

A multi-platform adaptation of the "Deception: Murder in Hong Kong" board game.

## 🚀 Quick Start - Backend (Python / FastAPI)

The backend uses Redis for real-time state and Supabase for persistence.

### Option A: Using Docker (Recommended)
This runs both the API and Redis in isolated containers.
```bash
# Start everything
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Stop
docker-compose down
```

### Option B: Local Development
Ensure you have Redis running locally first.
```bash
cd backend
# Run using the full path to UV if it's not in your PATH
& uv sync
& uv run uvicorn src.app.main:app --reload
```

---

## 📱 Quick Start - Frontend (Flutter)

Navigate to the `frontend` directory.
```bash
cd frontend
flutter pub get
flutter run
```
*Note: Ensure the backend URL in `lib/providers/game_provider.dart` matches your environment.*

---

## ☁️ Deployment on Render (Docker)

To deploy the Backend on Render using Docker while ensuring it only updates when the backend code changes:

1.  **Create a New Web Service** on Render.
2.  **Connect your GitHub Repository**.
3.  **Configure the following settings (as seen in your screenshot):**
    *   **Runtime**: `Docker`
    *   **Root Directory**: `backend`
        > [!IMPORTANT]
        > Setting this to `backend` ensures that Render **only** triggers a new deployment when files inside the `backend/` folder are changed. Changes to the `frontend/` folder will be ignored by Render.
    *   **Dockerfile Path**: `Dockerfile` (Render will look for `backend/Dockerfile`).
4.  **Environment Variables**:
    *   Add your `.env` variables (REDIS_HOST, SUPABASE_URL, etc.) in the **Environment** tab on Render.

---

## 🔑 Admin Setup
To assign the admin role to your email:
1. Update `ADMIN_EMAIL` and `SUPABASE_SERVICE_ROLE_KEY` in `.env`.
2. Run the migration script:
```bash
docker-compose exec backend uv run src/app/scripts/migrate_admin.py
```
