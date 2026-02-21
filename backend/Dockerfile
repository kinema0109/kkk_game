# Use a slim Python 3.12 image
FROM python:3.12-slim

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set working directory
WORKDIR /app

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock ./

# Install dependencies without creating a virtualenv (easier for Docker)
RUN uv sync --frozen --no-cache

# Place the project's code in the container
COPY . .

# Expose the API port
EXPOSE 8000

# Start the application using uv to run the fast api
CMD ["uv", "run", "uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
