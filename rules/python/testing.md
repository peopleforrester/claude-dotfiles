<!-- Tokens: ~500 | Lines: 70 | Compatibility: Claude Code 2.1+ -->
# Python Testing Rules

Extends `common/testing.md` with Python-specific testing constraints.

## Always

### Framework
- Use `pytest` as the test runner (not unittest)
- Use `pytest-cov` for coverage reporting
- Use `hypothesis` for property-based testing on utilities
- Use `pytest-asyncio` for async test functions
- Use `conftest.py` for shared fixtures

### Patterns
```python
# PREFER: Fixtures over setup/teardown
@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()

# PREFER: Parametrize for multiple cases
@pytest.mark.parametrize("input_val, expected", [
    ("hello", "HELLO"),
    ("", ""),
    ("123", "123"),
])
def test_uppercase(input_val: str, expected: str) -> None:
    assert uppercase(input_val) == expected

# PREFER: pytest.raises with match
def test_invalid_input_raises() -> None:
    with pytest.raises(ValueError, match="must be positive"):
        calculate(-1)

# PREFER: Async test support
@pytest.mark.asyncio
async def test_fetch_user(mock_client: AsyncClient) -> None:
    response = await mock_client.get("/users/1")
    assert response.status_code == 200
```

### Coverage
- Minimum 80% line coverage
- 100% coverage on business logic and data validation
- Use `# pragma: no cover` only for genuinely untestable code (with comment)

### Organization
```
tests/
  conftest.py          # Shared fixtures
  test_models.py       # Unit tests for models
  test_services.py     # Unit tests for services
  test_api.py          # Integration tests for API
  e2e/                 # End-to-end tests
```

## Never

- Use `unittest.TestCase` in new code (use pytest functions)
- Mock what you don't own — wrap external APIs and test the wrapper
- Use `time.sleep()` in tests — use async patterns or mock time
- Share mutable state between test functions
