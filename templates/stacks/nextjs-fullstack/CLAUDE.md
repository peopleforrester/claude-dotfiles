<!-- Tokens: ~1,600 (target: 1,500) | Lines: 92 | Compatibility: Claude Code 2.1+ -->
# Next.js Fullstack Project

A Next.js 14+ fullstack application with App Router, Server Components, and Prisma.

## Stack

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript 5.x (strict)
- **Database**: PostgreSQL with Prisma ORM
- **Auth**: NextAuth.js v5 (Auth.js)
- **Styling**: Tailwind CSS + shadcn/ui
- **Testing**: Vitest + Playwright
- **Package Manager**: pnpm

## Commands

```bash
pnpm dev                  # Dev server (localhost:3000)
pnpm build                # Production build
pnpm start                # Start production server
pnpm lint                 # Next.js lint
pnpm typecheck            # TypeScript check
pnpm test                 # Vitest unit tests
pnpm test:e2e             # Playwright e2e tests
pnpm db:push              # Push schema changes (dev)
pnpm db:migrate           # Create and apply migration
pnpm db:generate          # Generate Prisma client
pnpm db:studio            # Open Prisma Studio
pnpm db:seed              # Seed database
```

## Key Directories

```
app/
├── layout.tsx            # Root layout (providers)
├── page.tsx              # Home page
├── globals.css           # Global styles
├── (auth)/               # Auth route group
│   ├── login/page.tsx
│   └── register/page.tsx
├── (dashboard)/          # Dashboard route group
│   ├── layout.tsx        # Dashboard layout
│   └── settings/page.tsx
├── api/                  # API routes
│   └── [...]/route.ts
└── actions/              # Server Actions
    └── user.ts

components/
├── ui/                   # shadcn/ui components
├── forms/                # Form components
└── layouts/              # Layout components

lib/
├── db.ts                 # Prisma client singleton
├── auth.ts               # Auth configuration
├── utils.ts              # Utility functions
└── validations.ts        # Zod schemas

prisma/
├── schema.prisma         # Database schema
├── migrations/           # Migration history
└── seed.ts               # Seed script
```

## Code Standards

- Server Components by default
- `'use client'` only for interactivity
- Server Actions for mutations
- Zod validation before all DB operations

## Architecture Decisions

- Route groups for organization without URL impact
- Parallel routes for modals and side panels
- Server Actions over API routes for forms
- Edge middleware for auth checks

## Gotchas

- `'use client'` children can still be Server Components
- `cookies()` / `headers()` makes the route dynamic
- Prisma: generate client after schema changes
- NextAuth v5: different API from v4

## Server Component

```tsx
// app/users/page.tsx - Server Component (default)
import { db } from '@/lib/db';

export default async function UsersPage() {
  const users = await db.user.findMany({
    orderBy: { createdAt: 'desc' },
  });

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

## Server Action

```tsx
// app/actions/user.ts
'use server';

import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';
import { userSchema } from '@/lib/validations';

export async function createUser(formData: FormData) {
  const validated = userSchema.parse({
    name: formData.get('name'),
    email: formData.get('email'),
  });

  await db.user.create({ data: validated });
  revalidatePath('/users');
}
```

## Prisma Schema Pattern

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## Environment Variables

```bash
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="..."
NEXTAUTH_URL="http://localhost:3000"
```

## Testing Strategy

- Unit: Utils, validations, Server Actions
- Component: React Testing Library
- E2E: Playwright for critical flows
- Use test database for Prisma tests
