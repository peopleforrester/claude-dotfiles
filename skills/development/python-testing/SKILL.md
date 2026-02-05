---
name: python-testing
description: |
  Comprehensive Python testing patterns using pytest. Covers fixtures,
  parametrize, async testing, mocking, property-based testing, and
  coverage analysis.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags: [python, testing, pytest, tdd]
---

# Python Testing Patterns

## Framework: pytest

### Project Setup
```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
addopts = "-v --tb=short --strict-markers"
markers = [
    "slow: marks tests as slow",
    "integration: marks integration tests",
]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "*/__init__.py"]

[tool.coverage.report]
fail_under = 80
show_missing = true
```

## Fixtures

### Basic Fixtures
```python
@pytest.fixture
def sample_user() -> User:
    return User(name="Test User", email="test@example.com")

@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()
```

### Factory Fixtures
```python
@pytest.fixture
def make_user():
    def _make_user(name: str = "Test", email: str | None = None) -> User:
        return User(
            name=name,
            email=email or f"{name.lower()}@example.com",
        )
    return _make_user
```

### Shared Fixtures (conftest.py)
```python
# tests/conftest.py
@pytest.fixture(scope="session")
def app():
    """Create application for testing."""
    app = create_app(testing=True)
    yield app

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()
```

## Parametrize

```python
@pytest.mark.parametrize("input_val, expected", [
    ("hello@example.com", True),
    ("invalid-email", False),
    ("", False),
    ("user@.com", False),
    ("user@domain.co.uk", True),
])
def test_validate_email(input_val: str, expected: bool) -> None:
    assert validate_email(input_val) == expected
```

## Async Testing

```python
import pytest_asyncio

@pytest_asyncio.fixture
async def async_client():
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client

@pytest.mark.asyncio
async def test_fetch_user(async_client: AsyncClient) -> None:
    response = await async_client.get("/api/users/1")
    assert response.status_code == 200
    assert response.json()["name"] == "Test User"
```

## Mocking

```python
from unittest.mock import AsyncMock, patch

def test_send_email(mocker):
    mock_send = mocker.patch("myapp.email.send_email")
    mock_send.return_value = True

    result = notify_user("user@example.com", "Hello")

    assert result is True
    mock_send.assert_called_once_with("user@example.com", "Hello")
```

## Property-Based Testing

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_is_idempotent(xs: list[int]) -> None:
    assert sorted(sorted(xs)) == sorted(xs)

@given(st.text(min_size=1))
def test_uppercase_preserves_length(s: str) -> None:
    assert len(s.upper()) == len(s)
```

## Exception Testing

```python
def test_invalid_input_raises() -> None:
    with pytest.raises(ValueError, match="must be positive"):
        calculate(-1)

def test_file_not_found_error() -> None:
    with pytest.raises(FileNotFoundError):
        load_config(Path("/nonexistent/path"))
```

## Test Organization

```
tests/
  conftest.py              # Shared fixtures
  unit/
    test_models.py         # Model unit tests
    test_services.py       # Service unit tests
    test_utils.py          # Utility unit tests
  integration/
    test_api.py            # API integration tests
    test_database.py       # Database integration tests
  e2e/
    test_workflows.py      # End-to-end workflows
```
