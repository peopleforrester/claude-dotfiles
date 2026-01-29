<!-- Tokens: ~1,400 (target: 1,500) | Lines: 80 | Compatibility: Claude Code 2.1+ -->
# API Backend

A REST or GraphQL API service with authentication, validation, and documentation.

## Stack

- **Type**: REST API / GraphQL
- **Language**: [TypeScript/Python/Go]
- **Framework**: [Express/FastAPI/Gin]
- **Database**: [PostgreSQL/MongoDB]
- **Auth**: JWT / OAuth 2.0
- **Docs**: OpenAPI 3.0 / GraphQL Playground

## Commands

```bash
[pm] dev              # Start dev server with hot reload
[pm] test             # Run API tests
[pm] test:integration # Integration tests only
[pm] lint             # Lint code
[pm] build            # Production build
[pm] start            # Start production server
[pm] db:migrate       # Run database migrations
[pm] docs:generate    # Generate API documentation
```

## Key Directories

```
src/
├── routes/           # Route handlers / Controllers
├── services/         # Business logic layer
├── repositories/     # Data access layer
├── middleware/       # Auth, logging, error handling
├── validators/       # Request validation schemas
├── models/           # Database models / entities
├── types/            # Type definitions
└── utils/            # Helpers and utilities

tests/
├── unit/             # Unit tests
├── integration/      # API integration tests
└── fixtures/         # Test data
```

## Code Standards

- Validate all input at API boundary
- Use DTOs for request/response shapes
- Centralized error handling middleware
- Consistent response format across endpoints

## API Design Principles

- RESTful: nouns for resources, HTTP verbs for actions
- Pagination: cursor-based for large datasets
- Filtering: query params with explicit operators
- Versioning: URL path (`/v1/`) or header

## Gotchas

- Always sanitize user input before database queries
- Rate limiting: implement early, not after abuse
- CORS: configure explicitly, avoid `*` in production
- Auth tokens: short expiry + refresh token pattern

## Response Format

```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "total": 100,
    "hasMore": true
  },
  "errors": null
}
```

## Error Response

```json
{
  "data": null,
  "errors": [
    {
      "code": "VALIDATION_ERROR",
      "message": "Invalid email format",
      "field": "email"
    }
  ]
}
```

## Authentication Flow

1. `POST /auth/login` → returns access + refresh tokens
2. Include `Authorization: Bearer {token}` on requests
3. `POST /auth/refresh` → exchange refresh for new access token
4. `POST /auth/logout` → invalidate refresh token

## Environment Variables

```
PORT=3000
DATABASE_URL=postgres://...
JWT_SECRET=...
JWT_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d
```

## Testing Strategy

- Unit: Service layer, validators, utilities
- Integration: Full request → response cycle
- Use test database or transactions with rollback
- Mock external services (payment, email)

## Security Checklist

- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] Rate limiting per IP/user
- [ ] HTTPS only in production
- [ ] Sensitive data encryption at rest
