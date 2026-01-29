<!-- Tokens: ~1,350 (target: 1,500) | Lines: 75 | Compatibility: Claude Code 2.1+ -->
# Python Project

A Python application using modern tooling and best practices.

## Stack

- **Language**: Python 3.12+
- **Package Manager**: uv (preferred) or pip
- **Testing**: pytest with pytest-cov
- **Linting**: ruff (replaces flake8, isort, pyupgrade)
- **Formatting**: black or ruff format
- **Type Checking**: mypy (strict mode)

## Commands

```bash
uv run python -m pytest           # Run tests
uv run python -m pytest -v        # Verbose test output
uv run python -m pytest --cov     # Run with coverage
uv run ruff check .               # Lint code
uv run ruff check . --fix         # Auto-fix lint issues
uv run ruff format .              # Format code
uv run mypy src/                  # Type check
uv run python -m src.main         # Run application
```

## Key Directories

```
src/
├── __init__.py       # Package marker
├── main.py           # Application entry point
├── config.py         # Configuration management
├── models/           # Data models (Pydantic/dataclasses)
├── services/         # Business logic
└── utils/            # Helper functions

tests/
├── conftest.py       # Shared fixtures
├── unit/             # Unit tests
└── integration/      # Integration tests
```

## Code Standards

- Type hints required on all public functions
- Docstrings: Google style with Args, Returns, Raises
- Imports: stdlib → third-party → local (ruff handles sorting)
- Use `pathlib.Path` over `os.path`

## Architecture Decisions

- Pydantic for data validation and settings management
- Dependency injection via constructor parameters
- Async where I/O bound (httpx, asyncpg)

## Gotchas

- `uv sync` required after modifying `pyproject.toml`
- Virtual env in `.venv/` - activate with `source .venv/bin/activate`
- pytest discovers tests in `tests/` and files matching `test_*.py`
- mypy may need `# type: ignore` for untyped third-party libs

## Dependencies

Key packages in `pyproject.toml`:

- **pydantic**: Data validation and settings
- **httpx**: Async HTTP client
- **structlog**: Structured logging

## Environment Variables

Required (see `.env.example`):

```
LOG_LEVEL=INFO
DATABASE_URL=postgresql://...
```

## Testing Strategy

- Unit tests: Pure functions, no I/O
- Integration tests: Database, external APIs (use fixtures)
- Fixtures in `conftest.py` for shared setup
