---
name: django-patterns
description: |
  Django 5.x best practices. Covers ORM optimization, class-based views,
  middleware, Django REST Framework, signals, and deployment patterns.
  Use when building Django applications or reviewing Django code.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - django
    - framework
    - python
---

# Django Patterns

Modern Django 5.x patterns and best practices.

## Project Structure

```
project/
├── config/                 # Project settings (renamed from project/)
│   ├── settings/
│   │   ├── base.py        # Shared settings
│   │   ├── development.py # Dev overrides
│   │   └── production.py  # Prod overrides
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   └── users/
│       ├── models.py
│       ├── views.py
│       ├── serializers.py  # DRF serializers
│       ├── urls.py
│       ├── services.py     # Business logic
│       ├── selectors.py    # Complex queries
│       └── tests/
│           ├── test_models.py
│           ├── test_views.py
│           └── factories.py
└── manage.py
```

## ORM Optimization

### Select Related (FK joins)
```python
# Bad: N+1 queries
users = User.objects.all()
for user in users:
    print(user.profile.bio)  # Extra query per user

# Good: Single JOIN query
users = User.objects.select_related("profile").all()
```

### Prefetch Related (M2M and reverse FK)
```python
# Bad: N+1 queries for many-to-many
articles = Article.objects.all()
for article in articles:
    print(article.tags.all())  # Extra query per article

# Good: Two queries total (articles + tags)
articles = Article.objects.prefetch_related("tags").all()
```

### Only/Defer for Partial Loading
```python
# Load only needed fields
users = User.objects.only("id", "name", "email")

# Exclude heavy fields
articles = Article.objects.defer("body", "raw_html")
```

### Efficient Bulk Operations
```python
# Bulk create (single INSERT)
User.objects.bulk_create([
    User(name="Alice", email="alice@example.com"),
    User(name="Bob", email="bob@example.com"),
], batch_size=1000)

# Bulk update (single UPDATE)
User.objects.filter(is_active=False).update(is_active=True)

# F() expressions for atomic updates
from django.db.models import F
Product.objects.filter(id=product_id).update(stock=F("stock") - 1)
```

### Custom QuerySet Managers
```python
class ArticleQuerySet(models.QuerySet):
    def published(self):
        return self.filter(status="published", published_at__lte=timezone.now())

    def by_author(self, user):
        return self.filter(author=user)

class Article(models.Model):
    objects = ArticleQuerySet.as_manager()

# Chain: Article.objects.published().by_author(user)
```

## Views

### Class-Based Views (Generic)
```python
from django.views.generic import ListView, DetailView, CreateView

class ArticleListView(ListView):
    model = Article
    queryset = Article.objects.published().select_related("author")
    paginate_by = 20
    template_name = "articles/list.html"
```

### Django REST Framework ViewSets
```python
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return super().get_queryset().filter(is_active=True)

    @action(detail=True, methods=["post"])
    def deactivate(self, request, pk=None):
        user = self.get_object()
        user.is_active = False
        user.save(update_fields=["is_active"])
        return Response(status=status.HTTP_204_NO_CONTENT)
```

### DRF Serializers
```python
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "name", "email", "created_at"]
        read_only_fields = ["id", "created_at"]

    def validate_email(self, value):
        if User.objects.filter(email=value).exclude(pk=self.instance and self.instance.pk).exists():
            raise serializers.ValidationError("Email already in use.")
        return value
```

## Service Layer

```python
# apps/users/services.py
from django.db import transaction

class UserService:
    @staticmethod
    @transaction.atomic
    def create_user(*, name: str, email: str, role: str = "viewer") -> User:
        user = User.objects.create(name=name, email=email, role=role)
        Profile.objects.create(user=user)
        AuditLog.objects.create(action="user_created", target_id=user.id)
        return user
```

## Middleware

```python
import time
import logging

logger = logging.getLogger(__name__)

class RequestTimingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.perf_counter()
        response = self.get_response(request)
        elapsed = time.perf_counter() - start
        logger.info("%s %s %.4fs", request.method, request.path, elapsed)
        response["X-Process-Time"] = f"{elapsed:.4f}"
        return response
```

## Signals (Use Sparingly)

```python
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)
```

**Prefer service layer over signals** — signals create hidden coupling and
are difficult to debug. Use signals only for cross-app decoupling where
direct imports would create circular dependencies.

## Model Best Practices

```python
import uuid
from django.db import models

class TimeStampedModel(models.Model):
    """Abstract base with UUID primary key and timestamps."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class User(TimeStampedModel):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["email"]),
            models.Index(fields=["is_active", "-created_at"]),
        ]

    def __str__(self):
        return self.name
```

## Testing

```python
import pytest
from django.test import TestCase
from rest_framework.test import APIClient

class TestUserAPI(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create(name="Test", email="test@example.com")
        self.client.force_authenticate(user=self.user)

    def test_list_users(self):
        response = self.client.get("/api/users/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["results"]), 1)

    def test_create_user(self):
        response = self.client.post("/api/users/", {"name": "New", "email": "new@example.com"})
        self.assertEqual(response.status_code, 201)
```

### Factory Pattern (factory_boy)
```python
import factory

class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User

    name = factory.Faker("name")
    email = factory.LazyAttribute(lambda o: f"{o.name.lower().replace(' ', '.')}@example.com")
    is_active = True
```

## Checklist

- [ ] `select_related` for ForeignKey access in loops
- [ ] `prefetch_related` for ManyToMany access in loops
- [ ] Business logic in service layer, not views
- [ ] `F()` expressions for atomic field updates
- [ ] `transaction.atomic` for multi-model writes
- [ ] Custom QuerySet managers for reusable filters
- [ ] UUID primary keys for public-facing IDs
- [ ] Abstract TimeStampedModel base class
- [ ] Database indexes on filtered/sorted fields
- [ ] Tests use `force_authenticate` or factory patterns
