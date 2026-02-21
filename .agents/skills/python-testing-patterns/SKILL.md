---
name: python-testing-patterns
description: "Scalable Python testing patterns with pytest. Covers fixtures, mocking, async testing, database isolation, and integration testing strategies."
risk: unknown
source: community
---
# Python Testing Patterns

> **Philosophy:** Tests should be fast, isolated, and readable. They are the documentation and the safety net of your code.

## Core Testing Principles
1. **Pytest Over Unittest**: Use pytest for its powerful fixtures, plugins, and clean syntax.
2. **Arrange-Act-Assert**: Keep tests structured and predictable.
3. **Database Isolation**: Every test must start with a clean state. Use transactions/rollbacks.
4. **Fast Feedback**: Unit tests should run in milliseconds. Integration tests should be clearly separated.
5. **Coverage ≠ Quality**: Aim for 80%+, but focus on critical business logic first.

---

## Pytest Best Practices

### The Power of Fixtures
Use `conftest.py` for shared fixtures. Favor `scoping` correctly (function, module, session).
```python
# conftest.py
@pytest.fixture
def db_session():
    session = SessionLocal()
    try:
        yield session
    finally:
        session.rollback()
        session.close()
```

### Mocking & Patching
- Use `pytest-mock` (`mocker` fixture) over the standard `unittest.mock.patch` for better cleanup and readability.
- Mock external APIs (httpx, requests) using libraries like `respx` or `requests-mock`.

### Async Testing
Requires `pytest-asyncio`.
```python
@pytest.mark.asyncio
async def test_async_endpoint():
    result = await my_async_fn()
    assert result == "done"
```

---

## Testing Scenarios

### 1. API Testing (FastAPI/Django)
- Use `TestClient` (FastAPI) or `APIClient` (DRF).
- Test status codes, response schemas, and error messages.
- Mock background tasks (`celery`/`arq`) to verify they were called with the right params.

### 2. Database Testing
- **Don't use real production databases**. Use a dedicated test DB (Postgres container for CI).
- Use `factory_boy` for generating complex test data instead of manual dicts.
- Clear data after every test or use transaction rollbacks.

### 3. Integration Testing
- Test the interaction between multiple components/services.
- Use `testcontainers-python` to spin up real databases/Redis/external services for high-fidelity testing.

---

## Project Structure
```
project/
├── src/
└── tests/
    ├── conftest.py          # Shared fixtures
    ├── unit/                # Fast, isolated tests
    │   ├── test_logic.py
    │   └── ...
    └── integration/         # Slower, multi-component tests
        ├── test_api_flow.py
        └── ...
```

---

## Testing Anti-patterns
- **Hardcoded secrets in tests**: Use environment variables or fake values.
- **Tests depending on other tests**: Use fixtures to ensure independence.
- **Leaving files/DB records behind**: Cleanup in `finally` blocks or fixture teardowns.
- **Testing implementation, not behavior**: Focus on what the function *results* in, not *how* it does it.
- **Slow tests in unit suite**: Keep I/O out of unit tests.

---

## Decision Checklist
- [ ] Does the test follow the AAA pattern?
- [ ] are external dependencies (APIs, files) properly mocked?
- [ ] Is the database state isolated and cleaned up?
- [ ] Is the test independent of execution order?
- [ ] for async code, is `pytest-asyncio` being used correctly?
- [ ] are edge cases (None, empty, large data) covered?
