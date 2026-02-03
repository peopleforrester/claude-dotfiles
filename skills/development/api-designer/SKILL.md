---
name: api-designer
description: |
  API design and documentation assistant for REST and GraphQL APIs. Use when
  designing new endpoints, reviewing API structure, or creating API documentation.
  Follows industry best practices for consistent, intuitive API design.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - development
    - api
    - design
---

# API Designer

Design consistent, intuitive, and well-documented APIs.

## When to Use

- Designing new API endpoints
- Reviewing existing API structure
- Creating API documentation
- Planning API versioning strategy
- Designing error responses

## REST API Design Principles

### URL Structure

```
GET    /resources           # List resources
GET    /resources/:id       # Get single resource
POST   /resources           # Create resource
PUT    /resources/:id       # Replace resource
PATCH  /resources/:id       # Update resource partially
DELETE /resources/:id       # Delete resource
```

### Naming Conventions

- Use **nouns** for resources: `/users`, `/orders`, `/products`
- Use **plural** form: `/users` not `/user`
- Use **kebab-case** for multi-word: `/order-items`
- Use **path params** for identification: `/users/:id`
- Use **query params** for filtering: `/users?status=active`

### Nested Resources

```
GET /users/:userId/orders           # User's orders
GET /users/:userId/orders/:orderId  # Specific order
POST /users/:userId/orders          # Create order for user
```

Keep nesting shallow (max 2 levels).

## Request/Response Design

### Request Body

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "preferences": {
    "newsletter": true,
    "theme": "dark"
  }
}
```

- Use camelCase for property names
- Required fields should be documented
- Include validation constraints

### Success Response

```json
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2026-01-15T10:30:00Z"
  }
}
```

### List Response with Pagination

```json
{
  "data": [
    { "id": "1", "name": "Item 1" },
    { "id": "2", "name": "Item 2" }
  ],
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 100,
    "totalPages": 5
  },
  "links": {
    "self": "/items?page=1",
    "next": "/items?page=2",
    "last": "/items?page=5"
  }
}
```

### Error Response (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "The request body contains invalid data",
  "instance": "/users/123",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

## HTTP Status Codes

### Success (2xx)

| Code | Use When |
|------|----------|
| 200 OK | Request succeeded (GET, PUT, PATCH) |
| 201 Created | Resource created (POST) |
| 204 No Content | Success with no body (DELETE) |

### Client Errors (4xx)

| Code | Use When |
|------|----------|
| 400 Bad Request | Malformed request / validation error |
| 401 Unauthorized | Missing or invalid authentication |
| 403 Forbidden | Authenticated but not authorized |
| 404 Not Found | Resource doesn't exist |
| 409 Conflict | Resource conflict (duplicate) |
| 422 Unprocessable | Valid syntax but semantic error |
| 429 Too Many Requests | Rate limit exceeded |

### Server Errors (5xx)

| Code | Use When |
|------|----------|
| 500 Internal Error | Unexpected server error |
| 502 Bad Gateway | Upstream service error |
| 503 Unavailable | Service temporarily unavailable |

## API Versioning

### URL Path (Recommended)

```
/v1/users
/v2/users
```

### Header-based

```
Accept: application/vnd.api+json; version=1
```

## Authentication

### Bearer Token

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### API Key

```
X-API-Key: sk_live_abc123...
```

## Documentation Template

```markdown
## Create User

Creates a new user account.

### Request

`POST /v1/users`

#### Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |
| Content-Type | Yes | application/json |

#### Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | User's full name |
| email | string | Yes | Email address (unique) |

#### Example

\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com"
}
\`\`\`

### Response

#### 201 Created

\`\`\`json
{
  "data": {
    "id": "usr_123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2026-01-15T10:30:00Z"
  }
}
\`\`\`

#### 400 Bad Request

\`\`\`json
{
  "type": "validation_error",
  "title": "Validation Error",
  "status": 400,
  "errors": [
    { "field": "email", "message": "Email already exists" }
  ]
}
\`\`\`
```

## Design Checklist

- [ ] Resource names are nouns, plural
- [ ] HTTP methods used correctly
- [ ] Consistent response format
- [ ] Proper status codes
- [ ] Pagination for lists
- [ ] Versioning strategy defined
- [ ] Authentication documented
- [ ] Error format standardized
- [ ] Rate limiting documented
