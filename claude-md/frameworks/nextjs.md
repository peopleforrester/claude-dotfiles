<!-- Tokens: ~1,500 (target: 1,500) | Lines: 85 | Compatibility: Claude Code 2.1+ -->
# Next.js Project

A Next.js 14+ application using App Router and Server Components.

## Stack

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript 5.x (strict)
- **Styling**: Tailwind CSS
- **Database**: Prisma ORM (PostgreSQL)
- **Auth**: NextAuth.js v5
- **Testing**: Vitest + Playwright
- **Package Manager**: pnpm

## Commands

```bash
pnpm dev              # Start dev server (localhost:3000)
pnpm build            # Production build
pnpm start            # Start production server
pnpm lint             # Next.js lint
pnpm test             # Run unit tests
pnpm test:e2e         # Run Playwright tests
pnpm db:push          # Push schema to database
pnpm db:migrate       # Run migrations
pnpm db:studio        # Open Prisma Studio
```

## Key Directories

```
app/
├── layout.tsx        # Root layout
├── page.tsx          # Home page
├── globals.css       # Global styles
├── (auth)/           # Auth route group
│   ├── login/
│   └── register/
├── dashboard/
│   ├── layout.tsx    # Dashboard layout
│   └── page.tsx
└── api/              # API routes
    └── [...]/route.ts

components/
├── ui/               # shadcn/ui components
└── features/         # Feature components

lib/
├── db.ts             # Prisma client
├── auth.ts           # Auth configuration
└── utils.ts          # Utilities
```

## Code Standards

- Server Components by default; add `'use client'` only when needed
- Colocate loading.tsx, error.tsx, not-found.tsx with pages
- Use Server Actions for mutations
- Validate with Zod before database operations

## Architecture Decisions

- Route groups `(name)` for logical organization without URL impact
- Parallel routes `@slot` for complex layouts
- Intercepting routes `(.)` for modals
- Server Actions over API routes for forms

## Gotchas

- `'use client'` boundary: children can be Server Components
- `cookies()` and `headers()` make routes dynamic
- `revalidatePath()` / `revalidateTag()` for cache invalidation
- Middleware runs on Edge - limited Node.js APIs

## Server vs Client Components

```tsx
// Server Component (default) - can fetch data directly
async function UserList() {
  const users = await db.user.findMany();
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}

// Client Component - for interactivity
'use client';
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## Server Actions

```tsx
// app/actions.ts
'use server';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  await db.post.create({ data: { title } });
  revalidatePath('/posts');
}
```

## Environment Variables

```
DATABASE_URL=postgresql://...
NEXTAUTH_SECRET=...
NEXTAUTH_URL=http://localhost:3000
```

## Testing Strategy

- Unit: Utility functions, Server Actions
- Component: React Testing Library
- E2E: Playwright for critical user flows
- API: Test route handlers directly
