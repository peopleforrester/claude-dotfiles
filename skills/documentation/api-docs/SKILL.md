---
name: api-docs
description: |
  Generate API documentation from code or specifications. Use when documenting
  REST APIs, library APIs, or generating reference documentation. Supports
  OpenAPI, JSDoc, and markdown formats.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - documentation
    - api
    - reference
---

# API Documentation Generator

Create clear, comprehensive API documentation.

## When to Use

- Documenting REST API endpoints
- Writing library/SDK documentation
- Creating OpenAPI/Swagger specs
- Generating reference documentation

## REST API Documentation

### Endpoint Template

```markdown
## Create User

Creates a new user account.

`POST /api/v1/users`

### Authentication

Requires Bearer token with `users:write` scope.

### Request

#### Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |
| Content-Type | Yes | `application/json` |

#### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| email | string | Yes | User's email address |
| name | string | Yes | User's display name |
| role | string | No | User role. Default: `member` |

#### Example Request

\`\`\`bash
curl -X POST https://api.example.com/api/v1/users \
  -H "Authorization: Bearer sk_live_xxx" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "name": "John Doe",
    "role": "admin"
  }'
\`\`\`

### Response

#### Success (201 Created)

\`\`\`json
{
  "data": {
    "id": "usr_abc123",
    "email": "john@example.com",
    "name": "John Doe",
    "role": "admin",
    "createdAt": "2026-01-15T10:30:00Z"
  }
}
\`\`\`

#### Error (400 Bad Request)

\`\`\`json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request body",
    "details": [
      {
        "field": "email",
        "message": "Email is already registered"
      }
    ]
  }
}
\`\`\`

### Error Codes

| Code | Description |
|------|-------------|
| VALIDATION_ERROR | Request body validation failed |
| UNAUTHORIZED | Missing or invalid authentication |
| RATE_LIMITED | Too many requests |
```

## OpenAPI Specification

```yaml
openapi: 3.0.3
info:
  title: My API
  version: 1.0.0
  description: API for managing resources

servers:
  - url: https://api.example.com/v1
    description: Production

paths:
  /users:
    post:
      summary: Create user
      operationId: createUser
      tags:
        - Users
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/BadRequest'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          example: usr_abc123
        email:
          type: string
          format: email
        name:
          type: string
        createdAt:
          type: string
          format: date-time

    CreateUserRequest:
      type: object
      required:
        - email
        - name
      properties:
        email:
          type: string
          format: email
        name:
          type: string
          minLength: 1
          maxLength: 100

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
```

## Library Documentation

### Function Documentation

```typescript
/**
 * Formats a date according to the specified pattern.
 *
 * @param date - The date to format
 * @param pattern - Format pattern string
 * @param options - Formatting options
 * @returns Formatted date string
 *
 * @example
 * ```ts
 * formatDate(new Date('2026-01-15'), 'YYYY-MM-DD')
 * // => '2026-01-15'
 *
 * formatDate(new Date(), 'MMM D, YYYY', { locale: 'en-US' })
 * // => 'Jan 15, 2026'
 * ```
 *
 * @see {@link parseDate} for the inverse operation
 * @since 1.0.0
 */
export function formatDate(
  date: Date,
  pattern: string,
  options?: FormatOptions
): string;
```

### Class Documentation

```typescript
/**
 * HTTP client for making API requests.
 *
 * @example
 * ```ts
 * const client = new ApiClient({
 *   baseUrl: 'https://api.example.com',
 *   apiKey: 'sk_live_xxx'
 * });
 *
 * const users = await client.get('/users');
 * ```
 */
export class ApiClient {
  /**
   * Creates a new API client instance.
   *
   * @param config - Client configuration
   * @throws {ConfigError} If required options are missing
   */
  constructor(config: ClientConfig);

  /**
   * Makes a GET request.
   *
   * @param path - API endpoint path
   * @param params - Query parameters
   * @returns Response data
   *
   * @throws {ApiError} If the request fails
   */
  async get<T>(path: string, params?: QueryParams): Promise<T>;
}
```

## Documentation Sections

### Overview/Introduction

```markdown
# My SDK

Official SDK for the Example API.

## Features

- Full API coverage
- TypeScript support
- Automatic retries
- Rate limit handling

## Installation

\`\`\`bash
npm install @example/sdk
\`\`\`

## Quick Start

\`\`\`typescript
import { Client } from '@example/sdk';

const client = new Client({ apiKey: 'sk_xxx' });
const user = await client.users.create({
  email: 'john@example.com'
});
\`\`\`
```

### Authentication

```markdown
## Authentication

All API requests require authentication via API key.

### API Keys

Generate API keys in your [dashboard](https://dashboard.example.com).

| Key Type | Prefix | Use Case |
|----------|--------|----------|
| Live | `sk_live_` | Production |
| Test | `sk_test_` | Development |

### Usage

Include your API key in the `Authorization` header:

\`\`\`
Authorization: Bearer sk_live_xxx
\`\`\`
```

### Error Handling

```markdown
## Errors

The API uses standard HTTP status codes.

### Error Response Format

\`\`\`json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User not found",
    "requestId": "req_abc123"
  }
}
\`\`\`

### Error Codes

| Code | Status | Description |
|------|--------|-------------|
| VALIDATION_ERROR | 400 | Invalid input |
| UNAUTHORIZED | 401 | Invalid API key |
| FORBIDDEN | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource not found |
| RATE_LIMITED | 429 | Too many requests |
```

## Quality Checklist

- [ ] All endpoints documented
- [ ] Request/response examples included
- [ ] Error codes explained
- [ ] Authentication documented
- [ ] Rate limits specified
- [ ] Examples are runnable
- [ ] Types/schemas defined
- [ ] Versioning explained
