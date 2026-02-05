---
name: backend-patterns
description: |
  Common backend development patterns for APIs, databases, caching,
  and service architecture. Language-agnostic principles with examples
  in Python, TypeScript, and Go.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags: [backend, api, database, caching, architecture]
---

# Backend Development Patterns

## API Design

### RESTful Conventions
```
GET    /api/users          # List (with pagination)
GET    /api/users/:id      # Read single
POST   /api/users          # Create
PUT    /api/users/:id      # Full update
PATCH  /api/users/:id      # Partial update
DELETE /api/users/:id      # Delete
```

### Response Format
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 142
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "must be a valid email" }
    ]
  }
}
```

### HTTP Status Codes
| Code | Use |
|------|-----|
| 200 | Successful read/update |
| 201 | Successful create |
| 204 | Successful delete |
| 400 | Validation error |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate) |
| 429 | Rate limited |
| 500 | Server error |

## Database Patterns

### Repository Pattern
Separate data access from business logic:
```
Service (business logic) → Repository (data access) → Database
```

### Query Optimization
- Add indexes for WHERE, JOIN, and ORDER BY columns
- Use EXPLAIN to verify query plans
- Avoid SELECT * — select only needed columns
- Use pagination for list endpoints (LIMIT/OFFSET or cursor-based)
- Batch operations instead of N+1 queries

### Migration Safety
- Always make migrations reversible
- Use `CREATE INDEX CONCURRENTLY` (PostgreSQL)
- Add columns as nullable first, then backfill, then add constraint
- Never rename columns — add new, migrate data, remove old

## Caching Patterns

### Cache-Aside (Lazy Loading)
```
1. Check cache for key
2. If miss: query database, store in cache, return
3. If hit: return cached value
4. On write: invalidate cache
```

### Cache Invalidation
- Time-based: TTL appropriate to data freshness needs
- Event-based: Invalidate on write/update
- Version-based: Include version in cache key

### What to Cache
- Database query results (especially aggregations)
- External API responses
- Computed values (rendered templates, transformed data)
- Session data

### What NOT to Cache
- Frequently changing data (< 1 second TTL)
- Sensitive data without encryption
- Large blobs that exceed memory budget

## Service Architecture

### Middleware Pattern
```
Request → Auth → Rate Limit → Validate → Handler → Response
                                              ↓
                                          Logging
```

### Health Check Endpoint
```
GET /health
{
  "status": "healthy",
  "checks": {
    "database": "connected",
    "cache": "connected",
    "disk": "sufficient"
  }
}
```

### Rate Limiting
- Per-user rate limits for authenticated endpoints
- Per-IP rate limits for public endpoints
- Return `429` with `Retry-After` header
- Use sliding window algorithm for accuracy

### Graceful Shutdown
1. Stop accepting new connections
2. Finish processing in-flight requests (with timeout)
3. Close database connections
4. Close cache connections
5. Exit
