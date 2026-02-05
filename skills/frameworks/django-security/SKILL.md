---
name: django-security
description: |
  Django security best practices. Covers CSRF, XSS, SQL injection prevention,
  authentication hardening, Content Security Policy, secrets management,
  and Django-specific security middleware configuration.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - security
    - django
    - framework
    - python
---

# Django Security Patterns

Security hardening for Django 5.x applications.

## Settings Hardening

```python
# config/settings/production.py

# HTTPS enforcement
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Cookie security
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"

# Content security
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = "DENY"

# Host validation
ALLOWED_HOSTS = [".example.com"]

# Secret key from environment
import os
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]  # Never hardcode
```

## CSRF Protection

```python
# All POST forms require CSRF token
# Template:
# {% csrf_token %}

# For API views using DRF, CSRF is handled via authentication classes
from rest_framework.authentication import SessionAuthentication

class CsrfExemptSessionAuth(SessionAuthentication):
    """Only use for webhook endpoints with signature verification."""
    def enforce_csrf(self, request):
        return  # Skip CSRF for verified webhooks only

# Verify webhook signatures instead of skipping CSRF blindly
import hmac
import hashlib

def verify_webhook_signature(payload: bytes, signature: str, secret: str) -> bool:
    expected = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature)
```

## Input Validation

```python
from django.core.validators import RegexValidator
from django.db import models

class User(models.Model):
    # Constrain input at model level
    username = models.CharField(
        max_length=30,
        validators=[RegexValidator(r"^[a-zA-Z0-9_]+$", "Alphanumeric and underscores only")],
    )
    email = models.EmailField(unique=True)

# DRF serializer validation
from rest_framework import serializers

class UserInputSerializer(serializers.Serializer):
    username = serializers.RegexField(r"^[a-zA-Z0-9_]+$", max_length=30)
    email = serializers.EmailField()

    def validate_username(self, value):
        if value.lower() in {"admin", "root", "system"}:
            raise serializers.ValidationError("Reserved username.")
        return value
```

## SQL Injection Prevention

```python
# Always use ORM or parameterized queries
# Good: ORM handles parameterization
users = User.objects.filter(name=user_input)

# Good: Parameterized raw SQL when ORM insufficient
from django.db import connection
with connection.cursor() as cursor:
    cursor.execute("SELECT * FROM users WHERE name = %s", [user_input])

# NEVER: String interpolation in SQL
# cursor.execute(f"SELECT * FROM users WHERE name = '{user_input}'")  # SQL INJECTION
```

## Authentication Hardening

```python
# Custom authentication backend with rate limiting
from django.contrib.auth.backends import ModelBackend
from django.core.cache import cache

class RateLimitedAuthBackend(ModelBackend):
    MAX_ATTEMPTS = 5
    LOCKOUT_SECONDS = 300  # 5 minutes

    def authenticate(self, request, username=None, password=None, **kwargs):
        cache_key = f"login_attempts:{username}"
        attempts = cache.get(cache_key, 0)

        if attempts >= self.MAX_ATTEMPTS:
            return None  # Account locked

        user = super().authenticate(request, username=username, password=password, **kwargs)

        if user is None:
            cache.set(cache_key, attempts + 1, self.LOCKOUT_SECONDS)
        else:
            cache.delete(cache_key)

        return user

# Password validation in settings
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator", "OPTIONS": {"min_length": 12}},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]
```

## Content Security Policy

```python
# Using django-csp
# pip install django-csp
MIDDLEWARE = [
    "csp.middleware.CSPMiddleware",
    # ...
]

CSP_DEFAULT_SRC = ("'self'",)
CSP_SCRIPT_SRC = ("'self'",)
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")  # Tighten if possible
CSP_IMG_SRC = ("'self'", "data:", "https:")
CSP_FONT_SRC = ("'self'",)
CSP_CONNECT_SRC = ("'self'",)
CSP_FRAME_SRC = ("'none'",)
CSP_OBJECT_SRC = ("'none'",)
```

## XSS Prevention

```python
# Django auto-escapes template variables by default
# {{ user_input }}  -> escaped
# {{ user_input|safe }}  -> DANGEROUS, only use for trusted HTML

# Sanitize rich text with bleach
import bleach

ALLOWED_TAGS = ["p", "b", "i", "a", "ul", "ol", "li", "br"]
ALLOWED_ATTRS = {"a": ["href", "title"]}

def sanitize_html(html_input: str) -> str:
    return bleach.clean(html_input, tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRS, strip=True)
```

## Secrets Management

```python
import os
from pathlib import Path

# Environment-based secrets (production)
DATABASE_URL = os.environ["DATABASE_URL"]
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
API_KEY = os.environ["EXTERNAL_API_KEY"]

# For local development, use .env file with django-environ
# pip install django-environ
import environ

env = environ.Env()
environ.Env.read_env(Path(__file__).resolve().parent / ".env")

SECRET_KEY = env("DJANGO_SECRET_KEY")
DEBUG = env.bool("DEBUG", default=False)
DATABASE_URL = env.db("DATABASE_URL")
```

## File Upload Security

```python
import os
import uuid
from django.core.exceptions import ValidationError

def validate_file_extension(value):
    ext = os.path.splitext(value.name)[1].lower()
    allowed = {".jpg", ".jpeg", ".png", ".gif", ".pdf"}
    if ext not in allowed:
        raise ValidationError(f"Unsupported file extension: {ext}")

def upload_to(instance, filename):
    """Generate random filename to prevent path traversal."""
    ext = os.path.splitext(filename)[1].lower()
    return f"uploads/{uuid.uuid4().hex}{ext}"

class Document(models.Model):
    file = models.FileField(
        upload_to=upload_to,
        validators=[validate_file_extension],
        max_length=255,
    )
```

## Security Middleware Stack

```python
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",      # Must be first
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "csp.middleware.CSPMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    # ... application middleware
]
```

## Dependency Auditing

```bash
# Check for known vulnerabilities
pip-audit
# or
safety check

# Pin dependencies with hashes
pip-compile --generate-hashes requirements.in
pip install --require-hashes -r requirements.txt
```

## Checklist

- [ ] `SECRET_KEY` loaded from environment, never committed
- [ ] HTTPS enforced with HSTS in production
- [ ] CSRF protection enabled on all state-changing endpoints
- [ ] SQL queries use ORM or parameterized raw SQL only
- [ ] User input validated at serializer/form level
- [ ] File uploads use random filenames and extension validation
- [ ] Rate limiting on authentication endpoints
- [ ] CSP headers configured
- [ ] Dependencies audited for known vulnerabilities
- [ ] Session cookies marked Secure, HttpOnly, SameSite
