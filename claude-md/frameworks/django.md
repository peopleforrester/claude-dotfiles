<!-- Tokens: ~1,450 (target: 1,500) | Lines: 84 | Compatibility: Claude Code 2.1+ -->
# Django Project

A Django 5+ application with Django REST Framework for APIs.

## Stack

- **Framework**: Django 5.0+
- **Language**: Python 3.12+
- **API**: Django REST Framework (DRF)
- **Database**: PostgreSQL
- **Task Queue**: Celery + Redis (optional)
- **Testing**: pytest-django
- **Package Manager**: uv

## Commands

```bash
uv run python manage.py runserver       # Dev server (localhost:8000)
uv run python manage.py shell           # Django shell
uv run python manage.py makemigrations  # Create migrations
uv run python manage.py migrate         # Apply migrations
uv run python manage.py createsuperuser # Create admin user
uv run pytest                           # Run tests
uv run pytest -v --cov                  # Tests with coverage
uv run ruff check . --fix               # Lint
uv run ruff format .                    # Format
```

## Key Directories

```
project/
├── settings/
│   ├── base.py       # Shared settings
│   ├── development.py
│   └── production.py
├── urls.py           # Root URL configuration
└── wsgi.py           # WSGI entry point

apps/
├── users/
│   ├── models.py     # User model
│   ├── views.py      # Views or ViewSets
│   ├── serializers.py  # DRF serializers
│   ├── urls.py       # App URLs
│   └── tests/
└── core/
    └── models.py     # Abstract base models

templates/            # Django templates
static/               # Static files
```

## Code Standards

- One app per domain concept
- Custom user model from the start
- Use `get_object_or_404()` in views
- Serializers for all API input/output

## Architecture Decisions

- Split settings by environment
- Abstract `TimeStampedModel` base class
- DRF ViewSets with routers for REST APIs
- Signals for cross-app communication

## Gotchas

- `AUTH_USER_MODEL` must be set before first migration
- `related_name` required to avoid reverse accessor clashes
- DRF serializers: `read_only_fields` in Meta, not on field
- `select_related` / `prefetch_related` for N+1 queries

## Model Pattern

```python
from django.db import models

class TimeStampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class Article(TimeStampedModel):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='articles'
    )

    def __str__(self):
        return self.title
```

## DRF ViewSet

```python
from rest_framework import viewsets
from .models import Article
from .serializers import ArticleSerializer

class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.select_related('author')
    serializer_class = ArticleSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
```

## Environment Variables

```
DJANGO_SETTINGS_MODULE=project.settings.development
DATABASE_URL=postgres://...
SECRET_KEY=...
DEBUG=True
```

## Testing Strategy

- Model tests: Validation, methods, managers
- API tests: `APITestCase`, `APIClient`
- Use `pytest-django` fixtures: `db`, `client`, `admin_client`
- Factory Boy for test data generation
