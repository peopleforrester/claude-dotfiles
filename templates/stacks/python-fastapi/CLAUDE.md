<!-- Tokens: ~1,550 (target: 1,500) | Lines: 88 | Compatibility: Claude Code 2.1+ -->
# Python FastAPI Project

A FastAPI application with async PostgreSQL, SQLAlchemy 2.0, and Alembic migrations.

## Stack

- **Framework**: FastAPI 0.110+
- **Language**: Python 3.12+
- **Database**: PostgreSQL 16 with asyncpg
- **ORM**: SQLAlchemy 2.0 (async)
- **Migrations**: Alembic
- **Validation**: Pydantic v2
- **Testing**: pytest + pytest-asyncio + httpx
- **Package Manager**: uv

## Commands

```bash
uv run uvicorn src.main:app --reload       # Dev server (localhost:8000)
uv run pytest                               # Run all tests
uv run pytest -v --cov=src                  # Tests with coverage
uv run pytest -k "test_user"                # Run specific tests
uv run alembic upgrade head                 # Apply all migrations
uv run alembic downgrade -1                 # Rollback one migration
uv run alembic revision --autogenerate -m "msg"  # Create migration
uv run ruff check . --fix                   # Lint and fix
uv run ruff format .                        # Format code
uv run mypy src/                            # Type check
```

## Key Directories

```
src/
├── main.py               # FastAPI app, mount routers
├── config.py             # Settings (pydantic-settings)
├── database.py           # Async engine, session factory
├── dependencies.py       # FastAPI dependencies (get_db, get_current_user)
├── exceptions.py         # Custom exceptions and handlers
├── models/               # SQLAlchemy models
│   ├── __init__.py
│   ├── base.py           # Base model with common fields
│   └── user.py
├── schemas/              # Pydantic schemas
│   ├── __init__.py
│   └── user.py           # UserCreate, UserResponse, etc.
├── routers/              # API route handlers
│   ├── __init__.py
│   └── users.py
├── services/             # Business logic
│   └── user_service.py
└── repositories/         # Data access layer
    └── user_repository.py

alembic/
├── versions/             # Migration files
├── env.py                # Alembic config
└── script.py.mako        # Migration template

tests/
├── conftest.py           # Fixtures (test db, async client)
├── routers/              # Router tests
└── services/             # Service tests
```

## Code Standards

- Async everywhere: `async def`, `await`
- Pydantic schemas for all API input/output
- Type hints on all functions
- SQLAlchemy 2.0 style: `select()`, not `query()`

## Architecture Decisions

- Three-layer: Router → Service → Repository
- Dependency injection via `Depends()`
- Background tasks for async operations
- Structured logging with structlog

## Gotchas

- Pydantic v2: `model_dump()` not `.dict()`
- SQLAlchemy async: use `async with` for sessions
- Alembic autogenerate misses some changes - always review
- Foreign keys: define relationship on both sides

## Endpoint Pattern

```python
@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> User:
    if await user_service.get_by_email(db, user_in.email):
        raise HTTPException(400, "Email already registered")
    return await user_service.create(db, user_in)
```

## Model Pattern

```python
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(default=func.now())
```

## Environment Variables

```bash
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/dbname
SECRET_KEY=your-secret-key
ENVIRONMENT=development
```

## Testing Strategy

- Use `httpx.AsyncClient` for API tests
- Separate test database with migrations
- Override dependencies with `app.dependency_overrides`
- Fixtures for common test data
