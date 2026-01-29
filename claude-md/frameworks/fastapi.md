<!-- Tokens: ~1,450 (target: 1,500) | Lines: 82 | Compatibility: Claude Code 2.1+ -->
# FastAPI Project

A FastAPI application with async database access and OpenAPI documentation.

## Stack

- **Framework**: FastAPI 0.110+
- **Language**: Python 3.12+
- **Database**: PostgreSQL with SQLAlchemy 2.0 (async)
- **Migrations**: Alembic
- **Validation**: Pydantic v2
- **Testing**: pytest with pytest-asyncio
- **Package Manager**: uv

## Commands

```bash
uv run uvicorn src.main:app --reload    # Dev server (localhost:8000)
uv run pytest                            # Run tests
uv run pytest -v --cov                   # Tests with coverage
uv run alembic upgrade head              # Run migrations
uv run alembic revision --autogenerate -m "description"  # Create migration
uv run ruff check . --fix                # Lint and fix
uv run ruff format .                     # Format code
uv run mypy src/                         # Type check
```

## Key Directories

```
src/
├── main.py           # FastAPI app, router mounting
├── config.py         # Settings with pydantic-settings
├── database.py       # Async engine, session factory
├── models/           # SQLAlchemy models
├── schemas/          # Pydantic schemas (request/response)
├── routers/          # API route handlers
├── services/         # Business logic layer
├── dependencies.py   # FastAPI dependencies
└── exceptions.py     # Custom exception handlers

alembic/
├── versions/         # Migration files
└── env.py            # Alembic configuration

tests/
├── conftest.py       # Fixtures (test DB, client)
└── routers/          # Router tests
```

## Code Standards

- Async everywhere: `async def`, `await`
- Pydantic models for all request/response bodies
- Dependency injection via `Depends()`
- Type hints required on all functions

## Architecture Decisions

- Repository pattern for database access
- Service layer between routers and repositories
- Background tasks via FastAPI's `BackgroundTasks`
- Structured logging with `structlog`

## Gotchas

- `async with` for database sessions - don't forget cleanup
- Pydantic v2: `model_dump()` not `dict()`, `model_validate()` not `parse_obj()`
- SQLAlchemy 2.0: use `select()` instead of `session.query()`
- Alembic autogenerate misses some changes - review migrations

## Endpoint Pattern

```python
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> UserResponse:
    user = await user_service.get_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

## Environment Variables

```
DATABASE_URL=postgresql+asyncpg://user:pass@localhost/db
SECRET_KEY=...
ENVIRONMENT=development
```

## Testing Strategy

- Use `httpx.AsyncClient` for async route testing
- Override dependencies with `app.dependency_overrides`
- Test database: separate DB or transactions with rollback
- Fixtures: `@pytest.fixture` with `scope="function"`

## OpenAPI Documentation

Auto-generated at:
- Swagger UI: `/docs`
- ReDoc: `/redoc`
- OpenAPI JSON: `/openapi.json`
