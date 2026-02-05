<!-- Tokens: ~650 | Lines: 90 | Compatibility: Claude Code 2.1+ -->
# Performance Rules

Constraints for efficient Claude Code usage and application performance.

## Model Selection

### Use Sonnet (Default) For
- Code generation and editing
- Bug fixes and refactoring
- File exploration and search
- Most daily development tasks

### Use Opus For
- Complex architecture decisions with multiple trade-offs
- Multi-file refactoring requiring deep context
- Security audits and vulnerability analysis
- Code reviews requiring nuanced judgment
- Debugging subtle, multi-layered issues

### Use Haiku For
- Simple questions and lookups
- Formatting and boilerplate generation
- Background analysis tasks (via subagents)
- Quick file exploration

## Context Window Management

### Always
- Keep CLAUDE.md files under 2,000 tokens (target: 1,500)
- Remove resolved TODO comments from active context
- Use `@file` references instead of copying full file contents
- Compact context proactively when approaching 80% capacity

### Never
- Paste entire files when a snippet would suffice
- Keep obsolete context from resolved discussions
- Repeat information already present in CLAUDE.md
- Include generated files (node_modules, dist, __pycache__)
- Enable more MCP tools than needed (each consumes context)

### MCP Tool Budget
| Active Tools | Impact |
|-------------|--------|
| < 20 | Optimal - full context available |
| 20-50 | Moderate - some context reduction |
| 50-80 | Heavy - noticeable context pressure |
| > 80 | Degraded - significant performance loss |

Keep active MCP tools under 80; disable unused servers.

## Prompt Engineering

### Batching Operations
- Group related file reads into single turns
- Combine small edits targeting the same file
- Run independent commands in parallel (multiple tool calls)

### Efficient Patterns
```markdown
# Good: Specific, bounded request
"Read src/auth/login.ts lines 50-80 and fix the null check"

# Poor: Vague, unbounded request
"Look at the auth code and make it better"
```

## Application Performance

### Database
- Add indexes on columns used in WHERE, JOIN, ORDER BY
- Use pagination for list endpoints (never return unbounded results)
- Avoid N+1 queries (use eager loading or data loaders)
- Set query timeouts to prevent runaway queries

### API
- Implement response caching for stable data (Cache-Control headers)
- Use compression (gzip/brotli) for responses > 1KB
- Paginate list endpoints with cursor-based pagination
- Set appropriate rate limits per endpoint

### Frontend
- Lazy load routes and heavy components
- Optimize images (WebP, responsive sizes, lazy loading)
- Minimize bundle size (tree-shaking, code splitting)
- Use virtual scrolling for lists > 100 items
- Debounce search inputs and resize handlers

### Caching Strategy
| Data Type | Cache Location | TTL |
|-----------|---------------|-----|
| Static assets | CDN + browser | 1 year (versioned) |
| API responses | HTTP cache | 5 min - 1 hour |
| Database queries | Application cache | 1 - 15 min |
| Session data | Memory/Redis | Session duration |
| Computed values | Memoization | Until deps change |

## Before Shipping

- [ ] No N+1 query patterns
- [ ] List endpoints are paginated
- [ ] Database queries have appropriate indexes
- [ ] Bundle size is within budget
- [ ] Images are optimized
- [ ] Caching is configured for stable data
