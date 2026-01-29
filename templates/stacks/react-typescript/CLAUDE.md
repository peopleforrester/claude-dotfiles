<!-- Tokens: ~1,500 (target: 1,500) | Lines: 85 | Compatibility: Claude Code 2.1+ -->
# React TypeScript Project

A React 18 application with TypeScript, Vite, and modern tooling.

## Stack

- **Framework**: React 18.3+
- **Language**: TypeScript 5.x (strict mode)
- **Build Tool**: Vite 5+
- **State**: React Query (server) + Zustand (client)
- **Styling**: Tailwind CSS 3.4+
- **Testing**: Vitest + React Testing Library
- **Package Manager**: pnpm

## Commands

```bash
pnpm dev              # Start dev server (localhost:5173)
pnpm build            # Production build
pnpm preview          # Preview production build locally
pnpm test             # Run tests
pnpm test:watch       # Tests in watch mode
pnpm test:ui          # Vitest UI
pnpm test:coverage    # Coverage report
pnpm lint             # ESLint check
pnpm lint:fix         # ESLint auto-fix
pnpm typecheck        # TypeScript check
pnpm format           # Prettier format
```

## Key Directories

```
src/
├── main.tsx              # Entry point
├── App.tsx               # Root component with providers
├── components/
│   ├── ui/               # Primitives (Button, Input, Modal)
│   └── features/         # Feature components (UserCard, ProductList)
├── hooks/                # Custom hooks (useAuth, useLocalStorage)
├── lib/
│   ├── api.ts            # API client (fetch wrapper)
│   └── utils.ts          # Utility functions
├── stores/               # Zustand stores
├── types/                # TypeScript types
├── styles/               # Global CSS, Tailwind config
└── routes/               # Route components (if using react-router)

tests/
├── setup.ts              # Test setup (vitest)
├── utils.tsx             # Test utilities, custom render
└── mocks/                # MSW handlers
```

## Code Standards

- Functional components only; no class components
- Props interface: `interface ButtonProps { ... }`
- Hooks for stateful logic; keep components presentational
- Named exports; default export only for route components

## Architecture Decisions

- React Query for all server state (caching, refetching)
- Zustand for client-only state (UI state, preferences)
- Colocation: component + test + styles in same folder
- Error boundaries at route level

## Gotchas

- Vite env vars: must prefix with `VITE_`
- React StrictMode: components render twice in dev
- React Query: staleTime vs cacheTime - know the difference
- Tailwind: purge looks at `content` paths - update if adding dirs

## Component Pattern

```tsx
interface UserCardProps {
  user: User;
  onSelect?: (id: string) => void;
}

export function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <div className="rounded-lg border p-4" onClick={() => onSelect?.(user.id)}>
      <h3 className="font-semibold">{user.name}</h3>
      <p className="text-gray-600">{user.email}</p>
    </div>
  );
}
```

## Custom Hook Pattern

```tsx
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}
```

## Environment Variables

```bash
VITE_API_URL=http://localhost:3000/api
VITE_PUBLIC_KEY=pk_test_...
```

## Testing Strategy

- Unit: Hooks, utilities, pure functions
- Component: User interactions, render output
- Integration: Feature flows with mocked API (MSW)
- Use `screen.getByRole()` over `getByTestId()`
