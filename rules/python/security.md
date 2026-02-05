<!-- Tokens: ~400 | Lines: 55 | Compatibility: Claude Code 2.1+ -->
# Python Security Rules

Extends `common/security.md` with Python-specific constraints.

## Always

### Input Validation
- Use Pydantic models for all API input validation
- Use `bleach` or `markupsafe` for HTML sanitization
- Validate file uploads with `python-magic` (content type, not extension)
- Use `secrets` module for token generation (not `random`)

### Dependencies
- Run `pip-audit` or `safety check` before releases
- Pin all dependencies in `pyproject.toml` with version constraints
- Use `uv lock` to generate reproducible lock files
- Review new packages on PyPI (check download stats, repo activity)

### Framework-Specific
```python
# Django: Use ORM, never raw SQL with user input
User.objects.filter(email=user_input)  # Safe
# cursor.execute(f"SELECT * FROM users WHERE email = '{user_input}'")  # DANGEROUS

# FastAPI: Use Pydantic for validation
class CreateUser(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)

@app.post("/users")
async def create_user(user: CreateUser):  # Auto-validated
    ...

# Flask: Use CSP and security headers
from flask_talisman import Talisman
Talisman(app)

# Subprocess: Never use shell=True with user input
subprocess.run(["ls", "-la", user_path], shell=False)  # Safe
# subprocess.run(f"ls -la {user_path}", shell=True)  # DANGEROUS
```

## Never

- Use `eval()`, `exec()`, or `compile()` with user input
- Use `pickle` to deserialize untrusted data (use JSON instead)
- Use `shell=True` in `subprocess` with user-provided arguments
- Store passwords with `hashlib` — use `bcrypt` or `argon2-cffi`
- Use `random` for security-sensitive operations — use `secrets`
- Disable SSL verification (`verify=False`) in production
