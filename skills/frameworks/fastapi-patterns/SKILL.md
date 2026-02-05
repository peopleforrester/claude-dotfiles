---
name: fastapi-patterns
description: |
  FastAPI 0.110+ best practices. Covers dependency injection, async endpoints,
  Pydantic v2 validation, middleware, background tasks, and deployment patterns.
  Use when building FastAPI applications or reviewing FastAPI code.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - fastapi
    - framework
    - python
---

# FastAPI Patterns

Modern FastAPI 0.110+ patterns and best practices with Pydantic v2.

## Project Structure

```
app/
├── main.py                 # App factory, middleware, startup
├── config.py               # Settings via pydantic-settings
├── dependencies.py         # Shared dependencies
├── models/                 # SQLAlchemy / SQLModel models
│   └── user.py
├── schemas/                # Pydantic request/response schemas
│   └── user.py
├── routers/                # Route handlers (one per domain)
│   └── users.py
├── services/               # Business logic layer
│   └── user_service.py
├── repositories/           # Data access layer
│   └── user_repo.py
└── tests/
    ├── conftest.py
    └── test_users.py
```

## Dependency Injection

### Database Session
```python
from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

engine = create_async_engine(settings.DATABASE_URL)
async_session = async_sessionmaker(engine, expire_on_commit=False)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### Service Dependencies
```python
from fastapi import Depends

async def get_user_service(
    db: AsyncSession = Depends(get_db),
    cache: Redis = Depends(get_redis),
) -> UserService:
    return UserService(db=db, cache=cache)

@router.get("/users/{user_id}")
async def get_user(
    user_id: UUID,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    return await service.get_by_id(user_id)
```

### Authentication Dependency
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> User:
    token = credentials.credentials
    payload = verify_jwt(token)  # Raises on invalid
    user = await db.get(User, payload["sub"])
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return user
```

## Pydantic v2 Schemas

### Request/Response Separation
```python
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from uuid import UUID
from datetime import datetime

class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr

class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    email: EmailStr | None = None

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    email: str
    created_at: datetime
```

### Validated Query Parameters
```python
from pydantic import BaseModel, Field

class PaginationParams(BaseModel):
    page: int = Field(default=1, ge=1)
    per_page: int = Field(default=20, ge=1, le=100)

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.per_page

@router.get("/users")
async def list_users(
    params: PaginationParams = Depends(),
    service: UserService = Depends(get_user_service),
) -> list[UserResponse]:
    return await service.list(offset=params.offset, limit=params.per_page)
```

## Async Patterns

### Concurrent External Calls
```python
import asyncio

@router.get("/dashboard")
async def dashboard(user: User = Depends(get_current_user)):
    stats, notifications, recent = await asyncio.gather(
        fetch_user_stats(user.id),
        fetch_notifications(user.id),
        fetch_recent_activity(user.id),
    )
    return {"stats": stats, "notifications": notifications, "recent": recent}
```

### Background Tasks
```python
from fastapi import BackgroundTasks

async def send_welcome_email(email: str, name: str) -> None:
    # Long-running task runs after response is sent
    await email_service.send(to=email, template="welcome", context={"name": name})

@router.post("/users", status_code=201)
async def create_user(
    body: UserCreate,
    background: BackgroundTasks,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await service.create(body)
    background.add_task(send_welcome_email, user.email, user.name)
    return user
```

## Middleware

```python
import time
from fastapi import FastAPI, Request
from starlette.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request timing
@app.middleware("http")
async def add_timing_header(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    elapsed = time.perf_counter() - start
    response.headers["X-Process-Time"] = f"{elapsed:.4f}"
    return response
```

## Error Handling

```python
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.message},
    )
```

## Configuration with pydantic-settings

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379"
    SECRET_KEY: str
    DEBUG: bool = False
    ALLOWED_ORIGINS: list[str] = ["http://localhost:3000"]

settings = Settings()
```

## Testing

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

@pytest.mark.anyio
async def test_create_user(client: AsyncClient):
    response = await client.post("/users", json={"name": "Alice", "email": "a@b.com"})
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Alice"
```

## Checklist

- [ ] Async endpoints for all I/O operations
- [ ] Dependency injection for DB sessions, services, auth
- [ ] Pydantic v2 schemas with `from_attributes=True`
- [ ] Separate request/response models (never expose DB models)
- [ ] Background tasks for email, webhooks, logging
- [ ] CORS middleware configured
- [ ] Exception handlers for custom error types
- [ ] Settings via pydantic-settings (not raw os.environ)
- [ ] Tests use httpx AsyncClient with ASGITransport
