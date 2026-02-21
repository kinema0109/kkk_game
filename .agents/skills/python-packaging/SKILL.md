---
name: python-packaging
description: "Master Python packaging and dependency management with uv. Covers pyproject.toml configuration, project initialization, dependency resolution, and distribution best-practices."
risk: unknown
source: community
---
# Python Packaging with uv

> **Philosophy:** Modern Python packaging should be fast, reproducible, and standardized using `pyproject.toml`.

## Core Principles
- **Use uv**: The fastest and most reliable tool for Python packaging (2025 standard).
- **pyproject.toml is Central**: All metadata, dependencies, and tool configurations live here.
- **Lock Every Project**: Always use `uv.lock` (replaces `requirements.txt`) for consistent environments.
- **Project Structure**: Use the `src` layout for libraries to ensure package imports work correctly during development and testing.

---

## Command Reference

### Initialize Project
```bash
# Create a new project using uv
uv init my-project
cd my-project

# Initialize a library (hatch backend by default)
uv init --lib my-library
```

### Dependency Management
```bash
# Add dependencies (updates pyproject.toml and uv.lock)
uv add fastapi pydantic

# Add development-only dependencies
uv add --dev pytest ruff mypy

# Remove a dependency
uv remove fastapi

# Install all project dependencies
uv sync
```

### Environment Management
```bash
# Create/refresh virtual environment (.venv)
uv venv

# Run a command within the environment
uv run python main.py
uv run pytest
```

---

## pyproject.toml Configuration

### Basic Metadata
```toml
[project]
name = "my-awesome-api"
version = "0.1.0"
description = "FastAPI project using uv"
readme = "README.md"
requires-python = ">=3.12"
license = { text = "MIT" }
authors = [{ name = "Your Name", email = "you@example.com" }]
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
]
dependencies = [
    "fastapi>=0.110.0",
    "pydantic>=2.6.0",
]
```

### Optional Dependencies (Extras)
```toml
[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.2.0",
    "mypy>=1.6.0",
]
docs = [
    "mkdocs>=1.5.0",
]
```

### Dev Tools Configuration
```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.mypy]
python_version = "3.12"
strict = true

[tool.pytest.ini_options]
testpaths = ["tests"]
```

---

## Advanced Workflows

### Script Execution
Define reusable scripts in `pyproject.toml` (PEP 723 support/standardized task runners):
```toml
[project.scripts]
start = "my_project.main:app"
cli = "my_project.cli:main"
```
Run with: `uv run start`

### Working with Private Registries
Configure in `uv.toml` or via environment variables:
```toml
[[tool.uv.index]]
name = "private"
url = "https://pypi.company.invalid/simple"
```

---

## Migration Guide
- **From requirements.txt**: `uv add -r requirements.txt`
- **From Pipenv/Poetry**: `uv init` + manual copy of dependencies + `uv sync`
- **From setup.py**: Replace with modern `[build-system]` and `[project]` in `pyproject.toml`.

---

## Common Pitfalls to Avoid
- **Ignoring uv.lock**: Never exclude `uv.lock` from version control (except for some library types).
- **Directly editing uv.lock**: Always use `uv add` or `uv sync` to modify.
- **Not using src/ layout**: For libraries, a flat structure can lead to accidental imports from the local directory instead of the installed package.
- **Mixing dependency managers**: Avoid using `pip` and `uv` in the same project; stick to `uv`.

---

## Decision Checklist
- [ ] Is `pyproject.toml` correctly populated?
- [ ] Have dev dependencies been separated into `[project.optional-dependencies]`?
- [ ] Is the `requires-python` constraint appropriate for 2025?
- [ ] Does `uv.lock` exist and is it up to date?
- [ ] Are tools (ruff, mypy) configured within `pyproject.toml`?
