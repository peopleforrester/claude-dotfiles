<!-- Tokens: ~500 | Lines: 70 | Compatibility: Claude Code 2.1+ -->
# TypeScript Design Patterns

Extends `common/patterns.md` with TypeScript-specific patterns.

## API Response Pattern
```typescript
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: { code: string; message: string } };

async function fetchUser(id: string): Promise<ApiResponse<User>> {
  try {
    const user = await db.users.findUnique({ where: { id } });
    if (!user) return { success: false, error: { code: 'NOT_FOUND', message: 'User not found' } };
    return { success: true, data: user };
  } catch (err) {
    return { success: false, error: { code: 'INTERNAL', message: 'Failed to fetch user' } };
  }
}
```

## Custom Hooks Pattern (React)
```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debounced;
}
```

## Repository Pattern
```typescript
interface Repository<T> {
  findById(id: string): Promise<T | null>;
  findAll(filter?: Partial<T>): Promise<T[]>;
  create(data: Omit<T, 'id'>): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<void>;
}
```

## Zod Validation Pattern
```typescript
const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  role: z.enum(['admin', 'user', 'guest']).default('user'),
});

type CreateUserInput = z.infer<typeof CreateUserSchema>;
```

## Error Boundary Pattern (React)
```typescript
class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) return this.props.fallback;
    return this.props.children;
  }
}
```

## References
- See `skills/patterns/typescript-patterns/SKILL.md` for comprehensive patterns
- See `skills/frameworks/react-patterns/SKILL.md` for React-specific patterns
- See `skills/frameworks/nextjs-patterns/SKILL.md` for Next.js patterns
