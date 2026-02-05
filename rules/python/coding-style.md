<!-- Tokens: ~600 | Lines: 80 | Compatibility: Claude Code 2.1+ -->
# Python Coding Style Rules

Extends `common/coding-style.md` with Python-specific constraints.

## Always

### Type Safety
- Add type annotations to all function signatures
- Use `Protocol` for structural typing (duck typing with type safety)
- Use `TypedDict` for dictionary shapes
- Use `dataclass(frozen=True, slots=True)` for value objects
- Use `Enum` or `StrEnum` for fixed sets of values

### Patterns
```python
# PREFER: Protocols over ABCs for interfaces
class Serializable(Protocol):
    def to_dict(self) -> dict[str, Any]: ...

# PREFER: Result pattern over exceptions for expected failures
@dataclass(frozen=True)
class Result(Generic[T]):
    value: T | None = None
    error: str | None = None

    @property
    def ok(self) -> bool:
        return self.error is None

# PREFER: match statements for complex branching (3.10+)
match command:
    case {"action": "create", "name": str(name)}:
        create_item(name)
    case {"action": "delete", "id": int(id_)}:
        delete_item(id_)

# PREFER: pathlib over os.path
config_path = Path.home() / ".config" / "myapp" / "config.toml"
```

### Project Setup
- Use `pyproject.toml` for all project configuration
- Use `uv` for package management
- Use `ruff` for linting and formatting (replaces flake8, isort, black)
- Use `mypy` with strict mode for type checking

### File Organization
- One class per file for complex classes
- Group related functions in modules
- Use `__init__.py` to define public API
- Keep files under 400 lines

## Never

- Use `type: ignore` without a comment explaining why
- Use mutable default arguments (`def foo(items=[])`)
- Use wildcard imports (`from module import *`)
- Use bare `except:` — always catch specific exceptions
- Use `os.path` when `pathlib` works (prefer `pathlib`)
- Use `print()` for logging — use the `logging` module
