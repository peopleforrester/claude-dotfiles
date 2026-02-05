---
name: django-verification
description: |
  Pre-deployment verification workflow for Django projects. Covers migration
  checks, security audit, performance profiling, dependency scanning,
  deployment readiness, and production configuration validation.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - verification
    - django
    - deployment
    - python
---

# Django Verification Workflow

Pre-deployment quality gates for Django 5.x applications.

## Verification Steps

### 1. Migration Check

```bash
# Detect missing migrations
python manage.py makemigrations --check --dry-run

# Show migration status
python manage.py showmigrations --list

# Check for conflicts
python manage.py makemigrations --check
```

```python
# Verify no migration conflicts exist
# test_migrations.py
import pytest
from django.core.management import call_command
from io import StringIO

@pytest.mark.django_db
def test_no_missing_migrations():
    out = StringIO()
    try:
        call_command("makemigrations", "--check", "--dry-run", stdout=out)
    except SystemExit:
        pytest.fail(f"Missing migrations detected: {out.getvalue()}")
```

### 2. System Check

```bash
# Run Django system checks (catches common misconfigurations)
python manage.py check --deploy

# Expected output in production:
# System check identified no issues (0 silenced).
```

Common issues caught by `--deploy`:
- Missing `SECURE_HSTS_SECONDS`
- `DEBUG = True` in production
- Missing `ALLOWED_HOSTS`
- Insecure `SECRET_KEY`

### 3. Security Audit

```bash
# Dependency vulnerability scan
pip-audit

# Django-specific security check
python manage.py check --deploy --tag security

# Check for hardcoded secrets
grep -rn "SECRET_KEY\s*=" --include="*.py" | grep -v "os.environ\|env("
grep -rn "PASSWORD\s*=" --include="*.py" | grep -v "os.environ\|env(\|validators\|HASHERS"
```

```python
# Automated security verification
# test_security.py
import pytest
from django.conf import settings

class TestSecuritySettings:
    def test_debug_disabled_in_production(self):
        if settings.DEPLOYMENT_ENV == "production":
            assert settings.DEBUG is False

    def test_secret_key_not_default(self):
        assert settings.SECRET_KEY != "django-insecure-placeholder"
        assert len(settings.SECRET_KEY) >= 50

    def test_https_enforced(self):
        if settings.DEPLOYMENT_ENV == "production":
            assert settings.SECURE_SSL_REDIRECT is True
            assert settings.SECURE_HSTS_SECONDS >= 31536000

    def test_csrf_cookie_secure(self):
        if settings.DEPLOYMENT_ENV == "production":
            assert settings.CSRF_COOKIE_SECURE is True
            assert settings.SESSION_COOKIE_SECURE is True
```

### 4. Test Suite

```bash
# Full test suite with coverage
pytest --cov=apps --cov-report=term-missing --cov-fail-under=80

# Run with warnings visible
pytest -W error::DeprecationWarning

# Run slow tests separately
pytest -m slow --timeout=60
```

### 5. Performance Checks

```python
# test_performance.py
import pytest
from django.test.utils import override_settings

@pytest.mark.django_db
class TestQueryPerformance:
    def test_list_view_query_count(self, django_assert_num_queries, auth_api_client):
        """List endpoint should use constant number of queries."""
        # Create test data
        UserFactory.create_batch(20)

        with django_assert_num_queries(3):  # auth + count + select
            auth_api_client.get("/api/users/")

    def test_detail_view_query_count(self, django_assert_num_queries, auth_api_client, user):
        with django_assert_num_queries(2):  # auth + select
            auth_api_client.get(f"/api/users/{user.id}/")
```

```bash
# Profile slow queries with django-debug-toolbar or django-silk
# Enable in development settings only
INSTALLED_APPS += ["silk"]
MIDDLEWARE += ["silk.middleware.SilkyMiddleware"]
```

### 6. Static Analysis

```bash
# Type checking
mypy apps/ --ignore-missing-imports

# Linting
ruff check apps/

# Format check (no changes)
ruff format --check apps/

# Import sorting check
ruff check --select I apps/
```

### 7. Deployment Readiness

```python
# test_deployment.py
import pytest
from django.conf import settings

class TestDeploymentConfig:
    def test_static_files_configured(self):
        assert hasattr(settings, "STATIC_ROOT")
        assert settings.STATIC_ROOT is not None

    def test_media_storage_configured(self):
        assert hasattr(settings, "DEFAULT_FILE_STORAGE")

    def test_logging_configured(self):
        assert "handlers" in settings.LOGGING
        assert "root" in settings.LOGGING or "loggers" in settings.LOGGING

    def test_cache_backend_not_local_memory(self):
        if settings.DEPLOYMENT_ENV == "production":
            backend = settings.CACHES["default"]["BACKEND"]
            assert "LocMemCache" not in backend

    def test_email_backend_not_console(self):
        if settings.DEPLOYMENT_ENV == "production":
            assert "Console" not in settings.EMAIL_BACKEND
```

### 8. Collectstatic Verification

```bash
# Verify static files collection works
python manage.py collectstatic --noinput --dry-run

# Check for missing static files referenced in templates
python manage.py findstatic --first admin/css/base.css
```

## Full Verification Script

```bash
#!/bin/bash
set -e

echo "=== Django Verification ==="

echo "[1/8] Migration check..."
python manage.py makemigrations --check --dry-run

echo "[2/8] System check..."
python manage.py check --deploy

echo "[3/8] Security audit..."
pip-audit --strict

echo "[4/8] Test suite..."
pytest --cov=apps --cov-fail-under=80 -q

echo "[5/8] Performance tests..."
pytest -m "not slow" -q

echo "[6/8] Static analysis..."
ruff check apps/
mypy apps/ --ignore-missing-imports

echo "[7/8] Static files..."
python manage.py collectstatic --noinput --dry-run > /dev/null

echo "[8/8] Deployment config..."
pytest tests/test_deployment.py -q

echo "=== All checks passed ==="
```

## Checklist

- [ ] No missing migrations (`makemigrations --check`)
- [ ] Django system check passes (`check --deploy`)
- [ ] No known dependency vulnerabilities
- [ ] Test suite passes with 80%+ coverage
- [ ] No N+1 queries in list endpoints
- [ ] Static analysis clean (ruff, mypy)
- [ ] Static files collectible
- [ ] Production settings validated
- [ ] No hardcoded secrets in codebase
- [ ] Logging configured for production
