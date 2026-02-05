---
name: nextjs-patterns
description: |
  Next.js 15+ App Router best practices. Covers server components, data fetching,
  caching, middleware, and deployment patterns. Use when building Next.js
  applications or reviewing Next.js code.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - nextjs
    - framework
---

# Next.js Patterns

Modern Next.js 15+ App Router patterns and best practices.

## Server vs Client Components

### Default to Server Components
```tsx
// app/users/page.tsx (Server Component by default)
export default async function UsersPage() {
  const users = await db.user.findMany(); // Direct DB access
  return <UserList users={users} />;
}
```

### Client Components for Interactivity
```tsx
'use client';

// Only add 'use client' when you need:
// - useState, useEffect, useRef
// - Event handlers (onClick, onChange)
// - Browser APIs (window, localStorage)
// - Third-party client libraries

export function SearchBar() {
  const [query, setQuery] = useState('');
  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}
```

### Composition Pattern
```tsx
// Server Component (parent) passes data to Client Component (child)
export default async function Page() {
  const data = await fetchData(); // Server-side
  return <InteractiveChart data={data} />; // Client-side interactivity
}
```

## Data Fetching

### Server Component Fetching
```tsx
// Direct async/await in Server Components
async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } });
  if (!user) notFound();
  return <div>{user.name}</div>;
}
```

### Parallel Data Fetching
```tsx
export default async function Dashboard() {
  // Fetch in parallel, not waterfall
  const [users, stats, recent] = await Promise.all([
    getUsers(),
    getStats(),
    getRecentActivity(),
  ]);

  return (
    <>
      <UserList users={users} />
      <StatsPanel stats={stats} />
      <ActivityFeed items={recent} />
    </>
  );
}
```

### Server Actions
```tsx
// app/actions.ts
'use server';

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  // Validate
  const validated = UserSchema.parse({ name, email });

  // Write to database
  await db.user.create({ data: validated });

  // Revalidate
  revalidatePath('/users');
}
```

## Caching and Revalidation

### Route Segment Config
```tsx
// Static page (default)
export const dynamic = 'auto';

// Always dynamic (no cache)
export const dynamic = 'force-dynamic';

// Revalidate every 60 seconds
export const revalidate = 60;
```

### On-Demand Revalidation
```tsx
import { revalidatePath, revalidateTag } from 'next/cache';

// Revalidate specific path
revalidatePath('/users');

// Revalidate by tag
revalidateTag('users');
```

## Middleware

```tsx
// middleware.ts (root level)
import { NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  // Authentication check
  const token = request.cookies.get('session');
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Add security headers
  const response = NextResponse.next();
  response.headers.set('X-Frame-Options', 'DENY');
  return response;
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
};
```

## File Structure

```
app/
├── layout.tsx              # Root layout (shared UI)
├── page.tsx                # Home page
├── loading.tsx             # Loading UI (Suspense)
├── error.tsx               # Error boundary
├── not-found.tsx           # 404 page
├── (auth)/                 # Route group (no URL segment)
│   ├── login/page.tsx
│   └── register/page.tsx
├── dashboard/
│   ├── layout.tsx          # Dashboard layout
│   ├── page.tsx
│   └── settings/page.tsx
└── api/
    └── users/route.ts      # API route handler
```

## Checklist

- [ ] Server Components by default (add 'use client' only when needed)
- [ ] Parallel data fetching with Promise.all
- [ ] Server Actions for mutations
- [ ] Proper loading.tsx and error.tsx at each route level
- [ ] Middleware for auth and security headers
- [ ] Caching configured per route
- [ ] Metadata exported for SEO
- [ ] Images use next/image with proper sizing
