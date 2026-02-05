---
name: django-tdd
description: |
  Test-driven development patterns for Django. Covers pytest-django setup,
  factory_boy factories, API testing with DRF, model testing, view testing,
  and integration test strategies with database transactions.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - tdd
    - django
    - testing
    - python
---

# Django TDD Patterns

Test-driven development workflow for Django 5.x with pytest.

## Setup

```ini
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings.test"
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "--reuse-db --tb=short -q"
markers = [
    "slow: marks tests as slow",
    "integration: marks integration tests",
]
```

```python
# config/settings/test.py
from .base import *

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}
PASSWORD_HASHERS = ["django.contrib.auth.hashers.MD5PasswordHasher"]  # Faster tests
EMAIL_BACKEND = "django.core.mail.backends.locmem.EmailBackend"
DEFAULT_FILE_STORAGE = "django.core.files.storage.InMemoryStorage"
```

## Factory Pattern with factory_boy

```python
# apps/users/tests/factories.py
import factory
from apps.users.models import User, Profile

class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User
        skip_postgeneration_save = True

    name = factory.Faker("name")
    email = factory.LazyAttribute(lambda o: f"{o.name.lower().replace(' ', '.')}@example.com")
    is_active = True

    @factory.post_generation
    def with_profile(self, create, extracted, **kwargs):
        if not create or not extracted:
            return
        ProfileFactory(user=self)

class ProfileFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Profile

    user = factory.SubFactory(UserFactory)
    bio = factory.Faker("paragraph")
```

## TDD Cycle: Red-Green-Refactor

### Step 1: Write Failing Test (Red)

```python
# apps/users/tests/test_services.py
import pytest
from apps.users.services import UserService
from apps.users.models import User

@pytest.mark.django_db
class TestUserService:
    def test_create_user_returns_user(self):
        user = UserService.create_user(name="Alice", email="alice@example.com")
        assert isinstance(user, User)
        assert user.name == "Alice"
        assert user.email == "alice@example.com"

    def test_create_user_creates_profile(self):
        user = UserService.create_user(name="Alice", email="alice@example.com")
        assert hasattr(user, "profile")
        assert user.profile is not None

    def test_create_user_duplicate_email_raises(self):
        UserService.create_user(name="Alice", email="alice@example.com")
        with pytest.raises(Exception):
            UserService.create_user(name="Bob", email="alice@example.com")
```

### Step 2: Minimal Implementation (Green)

```python
# apps/users/services.py
from django.db import transaction
from apps.users.models import User, Profile

class UserService:
    @staticmethod
    @transaction.atomic
    def create_user(*, name: str, email: str) -> User:
        user = User.objects.create(name=name, email=email)
        Profile.objects.create(user=user)
        return user
```

### Step 3: Refactor (Keep Green)

Add error handling, logging, etc. while tests remain passing.

## Model Testing

```python
# apps/articles/tests/test_models.py
import pytest
from apps.articles.models import Article
from apps.users.tests.factories import UserFactory

@pytest.mark.django_db
class TestArticle:
    def test_str_returns_title(self):
        article = Article(title="Hello World")
        assert str(article) == "Hello World"

    def test_published_manager_excludes_drafts(self):
        author = UserFactory()
        Article.objects.create(title="Published", author=author, status="published")
        Article.objects.create(title="Draft", author=author, status="draft")

        published = Article.objects.published()
        assert published.count() == 1
        assert published.first().title == "Published"

    def test_slug_auto_generated(self):
        author = UserFactory()
        article = Article.objects.create(title="My Article", author=author)
        assert article.slug == "my-article"
```

## API Testing with DRF

```python
# apps/users/tests/test_api.py
import pytest
from rest_framework.test import APIClient
from rest_framework import status
from apps.users.tests.factories import UserFactory

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def authenticated_client(api_client):
    user = UserFactory()
    api_client.force_authenticate(user=user)
    return api_client, user

@pytest.mark.django_db
class TestUserAPI:
    def test_list_requires_auth(self, api_client):
        response = api_client.get("/api/users/")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_list_returns_users(self, authenticated_client):
        client, user = authenticated_client
        UserFactory.create_batch(3)
        response = client.get("/api/users/")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data["results"]) == 4  # 3 + authenticated user

    def test_create_user(self, authenticated_client):
        client, _ = authenticated_client
        payload = {"name": "New User", "email": "new@example.com"}
        response = client.post("/api/users/", payload)
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["name"] == "New User"

    def test_create_user_invalid_email(self, authenticated_client):
        client, _ = authenticated_client
        payload = {"name": "New User", "email": "not-an-email"}
        response = client.post("/api/users/", payload)
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "email" in response.data

    def test_update_user(self, authenticated_client):
        client, user = authenticated_client
        response = client.patch(f"/api/users/{user.id}/", {"name": "Updated"})
        assert response.status_code == status.HTTP_200_OK
        user.refresh_from_db()
        assert user.name == "Updated"

    def test_delete_user(self, authenticated_client):
        client, _ = authenticated_client
        target = UserFactory()
        response = client.delete(f"/api/users/{target.id}/")
        assert response.status_code == status.HTTP_204_NO_CONTENT
```

## View Testing

```python
# apps/articles/tests/test_views.py
import pytest
from django.test import Client
from django.urls import reverse
from apps.users.tests.factories import UserFactory

@pytest.mark.django_db
class TestArticleViews:
    def test_list_view_status(self):
        client = Client()
        response = client.get(reverse("article-list"))
        assert response.status_code == 200

    def test_list_view_template(self):
        client = Client()
        response = client.get(reverse("article-list"))
        assert "articles/list.html" in [t.name for t in response.templates]

    def test_create_view_requires_login(self):
        client = Client()
        response = client.get(reverse("article-create"))
        assert response.status_code == 302  # Redirect to login
```

## Fixtures and Conftest

```python
# conftest.py (project root)
import pytest
from rest_framework.test import APIClient
from apps.users.tests.factories import UserFactory

@pytest.fixture
def user():
    return UserFactory()

@pytest.fixture
def admin_user():
    return UserFactory(is_staff=True, is_superuser=True)

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def auth_api_client(user):
    client = APIClient()
    client.force_authenticate(user=user)
    return client
```

## Testing Async Views

```python
import pytest
from django.test import AsyncClient

@pytest.mark.django_db
@pytest.mark.asyncio
class TestAsyncViews:
    async def test_async_endpoint(self):
        client = AsyncClient()
        response = await client.get("/api/async-data/")
        assert response.status_code == 200
```

## Coverage Configuration

```ini
# pyproject.toml
[tool.coverage.run]
source = ["apps"]
omit = ["*/migrations/*", "*/tests/*", "*/admin.py"]

[tool.coverage.report]
fail_under = 80
show_missing = true
```

## Test Commands

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=apps --cov-report=term-missing

# Run specific app
pytest apps/users/

# Run marked tests
pytest -m "not slow"

# Run in parallel
pytest -n auto  # requires pytest-xdist
```

## Checklist

- [ ] Every service method has a corresponding test
- [ ] API endpoints tested for auth, valid input, invalid input, edge cases
- [ ] Factory patterns used instead of raw `Model.objects.create`
- [ ] Test settings use in-memory DB and fast password hasher
- [ ] Coverage threshold set to 80% minimum
- [ ] Tests use `@pytest.mark.django_db` for database access
- [ ] Fixtures defined in conftest.py for reuse
- [ ] Integration tests marked separately from unit tests
