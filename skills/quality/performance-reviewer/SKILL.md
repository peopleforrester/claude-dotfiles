---
name: performance-reviewer
description: |
  Performance analysis and optimization. Use when reviewing code for performance
  issues, identifying bottlenecks, or optimizing slow operations. Covers frontend,
  backend, and database performance.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - quality
    - performance
    - optimization
---

# Performance Reviewer

Identify and resolve performance issues.

## When to Use

- Reviewing code for performance
- Investigating slow operations
- Optimizing database queries
- Improving frontend performance
- Pre-launch performance audit

## Common Performance Issues

### N+1 Query Problem

**Symptom**: Many database queries in a loop

```typescript
// Bad: N+1 queries
const users = await User.findAll();
for (const user of users) {
  user.orders = await Order.findByUserId(user.id); // N queries!
}

// Good: Eager loading
const users = await User.findAll({
  include: [{ model: Order }]
});

// Good: Batch loading
const users = await User.findAll();
const userIds = users.map(u => u.id);
const orders = await Order.findByUserIds(userIds);
const ordersByUser = groupBy(orders, 'userId');
users.forEach(u => u.orders = ordersByUser[u.id] || []);
```

### Missing Indexes

**Symptom**: Slow queries on filtered columns

```sql
-- Check for missing indexes
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;

-- Add index
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Unbounded Queries

**Symptom**: Loading entire tables

```typescript
// Bad: No limit
const allUsers = await User.findAll();

// Good: Paginated
const users = await User.findAll({
  limit: 20,
  offset: page * 20
});
```

### Synchronous Blocking

**Symptom**: Blocking event loop

```typescript
// Bad: Blocking file read
const data = fs.readFileSync('large-file.json');

// Good: Async read
const data = await fs.promises.readFile('large-file.json');

// Good: Streaming for large files
const stream = fs.createReadStream('large-file.json');
```

### Memory Leaks

**Symptom**: Growing memory usage

```typescript
// Bad: Growing array
const cache = [];
app.get('/data', (req, res) => {
  cache.push(req.body); // Never cleared!
});

// Good: Bounded cache with eviction
const cache = new LRUCache({ max: 1000 });
```

## Frontend Performance

### Bundle Size

```bash
# Analyze bundle
npx vite-bundle-visualizer

# Check specific package size
npx bundlephobia lodash
```

**Optimizations:**
- Tree-shake unused code
- Code-split by route
- Lazy load below-fold content
- Use lighter alternatives

```typescript
// Bad: Import entire library
import _ from 'lodash';

// Good: Import specific functions
import debounce from 'lodash/debounce';
```

### Render Performance

```typescript
// Bad: Re-renders on every parent render
function UserList({ users }) {
  return users.map(user => (
    <UserCard key={user.id} user={user} />
  ));
}

// Good: Memoize expensive components
const UserCard = React.memo(function UserCard({ user }) {
  return <div>{user.name}</div>;
});

// Good: Memoize expensive calculations
const sortedUsers = useMemo(
  () => users.sort((a, b) => a.name.localeCompare(b.name)),
  [users]
);
```

### Image Optimization

```tsx
// Bad: Unoptimized images
<img src="/large-photo.jpg" />

// Good: Optimized with Next.js
import Image from 'next/image';
<Image
  src="/photo.jpg"
  width={400}
  height={300}
  loading="lazy"
  placeholder="blur"
/>
```

## Backend Performance

### Caching

```typescript
// Add caching layer
const cache = new Redis();

async function getUser(id: string) {
  // Check cache first
  const cached = await cache.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  // Fetch from database
  const user = await db.user.findUnique({ where: { id } });

  // Cache for 5 minutes
  await cache.setex(`user:${id}`, 300, JSON.stringify(user));

  return user;
}
```

### Connection Pooling

```typescript
// Good: Connection pool
const pool = new Pool({
  max: 20,          // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### Async Operations

```typescript
// Bad: Sequential
const user = await getUser(id);
const orders = await getOrders(id);
const reviews = await getReviews(id);

// Good: Parallel
const [user, orders, reviews] = await Promise.all([
  getUser(id),
  getOrders(id),
  getReviews(id)
]);
```

## Database Performance

### Query Optimization

```sql
-- Check query plan
EXPLAIN ANALYZE SELECT ...;

-- Common optimizations:
-- 1. Add appropriate indexes
-- 2. Select only needed columns
-- 3. Use LIMIT for pagination
-- 4. Avoid SELECT *
-- 5. Use JOINs instead of subqueries when appropriate
```

### Index Strategy

| Query Pattern | Index Type |
|---------------|------------|
| Equality (=) | B-tree |
| Range (<, >, BETWEEN) | B-tree |
| Text search | GIN/Full-text |
| JSON fields | GIN |
| Geospatial | GiST |

## Performance Metrics

### Core Web Vitals

| Metric | Target | Description |
|--------|--------|-------------|
| LCP | < 2.5s | Largest Contentful Paint |
| FID | < 100ms | First Input Delay |
| CLS | < 0.1 | Cumulative Layout Shift |

### Backend Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| P50 Latency | < 100ms | Median response time |
| P99 Latency | < 500ms | 99th percentile |
| Error Rate | < 0.1% | Failed requests |
| Throughput | Varies | Requests per second |

## Performance Review Checklist

### Database

- [ ] Queries use indexes effectively
- [ ] No N+1 query patterns
- [ ] Results are paginated
- [ ] Connections are pooled
- [ ] Slow query logging enabled

### Backend

- [ ] Heavy operations are async
- [ ] Appropriate caching in place
- [ ] No memory leaks
- [ ] Parallel where possible
- [ ] Timeouts configured

### Frontend

- [ ] Bundle size optimized
- [ ] Images optimized and lazy-loaded
- [ ] Code-splitting implemented
- [ ] Expensive renders memoized
- [ ] Core Web Vitals passing

## Profiling Tools

### Node.js

```bash
# CPU profiling
node --prof app.js
node --prof-process isolate-*.log > processed.txt

# Memory profiling
node --inspect app.js
# Open chrome://inspect
```

### Frontend

```javascript
// Performance timing
performance.mark('start');
// ... operation ...
performance.mark('end');
performance.measure('operation', 'start', 'end');
console.log(performance.getEntriesByName('operation'));
```

### Database

```sql
-- PostgreSQL: Enable slow query log
ALTER SYSTEM SET log_min_duration_statement = 100;
SELECT pg_reload_conf();
```
