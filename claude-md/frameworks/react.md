<!-- Tokens: ~1,400 (target: 1,500) | Lines: 80 | Compatibility: Claude Code 2.1+ -->
# React Project

A React 18+ application with modern patterns and TypeScript.

## Stack

- **Framework**: React 18+ with TypeScript
- **Build Tool**: Vite 5+
- **State Management**: React Query + Zustand (or Context)
- **Styling**: Tailwind CSS or CSS Modules
- **Testing**: Vitest + React Testing Library
- **Package Manager**: pnpm

## Commands

```bash
pnpm dev              # Start dev server (localhost:5173)
pnpm build            # Production build
pnpm preview          # Preview production build
pnpm test             # Run tests
pnpm test:watch       # Tests in watch mode
pnpm test:coverage    # Coverage report
pnpm lint             # ESLint check
pnpm lint:fix         # ESLint auto-fix
pnpm typecheck        # TypeScript check
```

## Key Directories

```
src/
├── main.tsx          # Application entry
├── App.tsx           # Root component
├── components/
│   ├── ui/           # Reusable primitives (Button, Input)
│   └── features/     # Feature-specific components
├── hooks/            # Custom React hooks
├── lib/              # Utilities, API client
├── stores/           # Zustand stores (if used)
├── types/            # TypeScript definitions
└── styles/           # Global styles

tests/
└── setup.ts          # Test configuration
```

## Code Standards

- Functional components only (no class components)
- Custom hooks for reusable stateful logic
- Props interfaces named `{Component}Props`
- Memoize expensive computations with `useMemo`

## Architecture Decisions

- Colocation: component, styles, tests in same directory
- Container/presenter pattern for complex components
- React Query for server state, Zustand for client state
- Error boundaries at route level

## Gotchas

- StrictMode renders components twice in dev (intentional)
- `useEffect` cleanup runs before every re-run, not just unmount
- Keys must be stable and unique - avoid array indices
- State updates are batched - multiple `setState` = one render

## Component Pattern

```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({ variant = 'primary', children, onClick }: ButtonProps) {
  return (
    <button className={styles[variant]} onClick={onClick}>
      {children}
    </button>
  );
}
```

## Testing Strategy

- Unit: Utility functions, custom hooks
- Component: User interactions, render output
- Use `screen.getByRole()` over `getByTestId()`
- Mock API calls with MSW (Mock Service Worker)

## Performance Patterns

- `React.lazy()` for route-based code splitting
- `useMemo` for expensive derived state
- `useCallback` for stable function references passed to children
- Virtualize long lists with `@tanstack/react-virtual`

## Environment Variables

Vite requires `VITE_` prefix:

```
VITE_API_URL=http://localhost:3000
VITE_PUBLIC_KEY=...
```
