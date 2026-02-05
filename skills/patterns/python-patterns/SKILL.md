---
name: python-patterns
description: |
  Python 3.10+ best practices, patterns, and idioms. Covers type hints, async,
  dataclasses, protocols, and modern Python tooling. Use when writing Python code,
  reviewing Python patterns, or learning idiomatic Python.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - python
    - language
---

# Python Patterns

Modern Python 3.10+ patterns and best practices.

## Type Hints

### Strict Typing
```python
from typing import TypeVar, Protocol, Optional
from collections.abc import Sequence

T = TypeVar('T')

def first_or_none(items: Sequence[T]) -> Optional[T]:
    return items[0] if items else None
```

### Protocols (Structural Typing)
```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Renderable(Protocol):
    def render(self) -> str: ...

class HtmlWidget:
    def render(self) -> str:
        return "<div>widget</div>"

def display(item: Renderable) -> None:
    print(item.render())

display(HtmlWidget())  # Works - structural match
```

### TypedDict for Structured Data
```python
from typing import TypedDict, NotRequired

class UserConfig(TypedDict):
    name: str
    email: str
    theme: NotRequired[str]  # Optional key
```

## Dataclasses and Immutability

### Frozen Dataclasses
```python
from dataclasses import dataclass, field

@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float

    def distance_to(self, other: "Point") -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5
```

### Pydantic for Validation
```python
from pydantic import BaseModel, Field, field_validator

class CreateUser(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: str
    age: int = Field(ge=0, le=150)

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        if '@' not in v:
            raise ValueError('Invalid email')
        return v.lower()
```

## Async Patterns

### Structured Concurrency
```python
import asyncio

async def fetch_all(urls: list[str]) -> list[str]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch(url)) for url in urls]
    return [t.result() for t in tasks]
```

### Async Context Managers
```python
from contextlib import asynccontextmanager
from typing import AsyncIterator

@asynccontextmanager
async def db_transaction() -> AsyncIterator[Connection]:
    conn = await get_connection()
    try:
        yield conn
        await conn.commit()
    except Exception:
        await conn.rollback()
        raise
    finally:
        await conn.close()
```

## Error Handling

### Result Pattern
```python
from dataclasses import dataclass
from typing import Generic, TypeVar, Union

T = TypeVar('T')
E = TypeVar('E', bound=Exception)

@dataclass(frozen=True)
class Ok(Generic[T]):
    value: T

@dataclass(frozen=True)
class Err(Generic[E]):
    error: E

Result = Union[Ok[T], Err[E]]

def divide(a: float, b: float) -> Result[float, ValueError]:
    if b == 0:
        return Err(ValueError("Division by zero"))
    return Ok(a / b)
```

### Match Statements (3.10+)
```python
match command.split():
    case ["quit"]:
        sys.exit(0)
    case ["go", direction]:
        move(direction)
    case ["get", item] if item in inventory:
        pick_up(item)
    case _:
        print(f"Unknown command: {command}")
```

## Tooling

| Tool | Purpose | Command |
|------|---------|---------|
| uv | Package management | `uv add package` |
| ruff | Linting + formatting | `ruff check . && ruff format .` |
| mypy | Type checking | `mypy src/ --strict` |
| pytest | Testing | `pytest -xvs` |
| pyright | Type checking (fast) | `pyright src/` |

## Checklist

- [ ] Type hints on all public functions
- [ ] Dataclasses for data containers (not plain dicts)
- [ ] Async for I/O-bound operations
- [ ] Match statements for complex branching (3.10+)
- [ ] Protocols for duck typing
- [ ] Pydantic for input validation
- [ ] uv for package management
- [ ] ruff for linting and formatting
