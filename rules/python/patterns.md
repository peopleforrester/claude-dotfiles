<!-- Tokens: ~500 | Lines: 70 | Compatibility: Claude Code 2.1+ -->
# Python Design Patterns

Extends `common/patterns.md` with Python-specific patterns.

## Protocol Pattern (Structural Typing)
```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Serializable(Protocol):
    def to_dict(self) -> dict[str, Any]: ...

class User:
    def to_dict(self) -> dict[str, Any]:
        return {"name": self.name, "email": self.email}

# User satisfies Serializable without explicit inheritance
def serialize(obj: Serializable) -> str:
    return json.dumps(obj.to_dict())
```

## Dataclass as DTO
```python
@dataclass(frozen=True, slots=True)
class UserResponse:
    id: str
    name: str
    email: str
    created_at: datetime

    @classmethod
    def from_model(cls, user: UserModel) -> "UserResponse":
        return cls(id=user.id, name=user.name, email=user.email, created_at=user.created_at)
```

## Context Manager Pattern
```python
@contextmanager
def database_transaction(session: Session):
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
```

## Repository Pattern
```python
class UserRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    async def find_by_id(self, user_id: str) -> User | None:
        return await self._session.get(User, user_id)

    async def find_all(self, *, limit: int = 20, offset: int = 0) -> list[User]:
        stmt = select(User).limit(limit).offset(offset)
        result = await self._session.execute(stmt)
        return list(result.scalars())

    async def create(self, data: CreateUserInput) -> User:
        user = User(**data.model_dump())
        self._session.add(user)
        await self._session.flush()
        return user
```

## Dependency Injection (FastAPI)
```python
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session

async def get_user_repo(db: AsyncSession = Depends(get_db)) -> UserRepository:
    return UserRepository(db)

@app.get("/users/{user_id}")
async def get_user(user_id: str, repo: UserRepository = Depends(get_user_repo)):
    user = await repo.find_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404)
    return user
```

## References
- See `skills/patterns/python-patterns/SKILL.md` for comprehensive patterns
- See `skills/frameworks/fastapi-patterns/SKILL.md` for FastAPI patterns
- See `skills/frameworks/django-patterns/SKILL.md` for Django patterns
