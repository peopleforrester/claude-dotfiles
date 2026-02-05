---
name: react-patterns
description: |
  React 19+ best practices and patterns. Covers hooks, composition, server
  components, performance optimization, and state management. Use when
  building React components or reviewing React code.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - react
    - framework
---

# React Patterns

Modern React 19+ patterns and best practices.

## Component Patterns

### Composition Over Prop Drilling
```tsx
// Compose with children instead of passing many props
<Card>
  <Card.Header>
    <Card.Title>User Profile</Card.Title>
  </Card.Header>
  <Card.Body>
    <UserInfo user={user} />
  </Card.Body>
  <Card.Footer>
    <Button onClick={save}>Save</Button>
  </Card.Footer>
</Card>
```

### Render Props for Flexibility
```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, i) => (
        <li key={keyExtractor(item)}>{renderItem(item, i)}</li>
      ))}
    </ul>
  );
}
```

## Hook Patterns

### Custom Data Fetching Hook
```tsx
function useQuery<T>(key: string, fetcher: () => Promise<T>) {
  const [state, setState] = useState<{
    data: T | null;
    error: Error | null;
    isLoading: boolean;
  }>({ data: null, error: null, isLoading: true });

  useEffect(() => {
    let cancelled = false;
    setState(prev => ({ ...prev, isLoading: true }));

    fetcher()
      .then(data => { if (!cancelled) setState({ data, error: null, isLoading: false }); })
      .catch(error => { if (!cancelled) setState({ data: null, error, isLoading: false }); });

    return () => { cancelled = true; };
  }, [key]);

  return state;
}
```

### useCallback for Stable References
```tsx
const handleSubmit = useCallback(
  async (data: FormData) => {
    await api.submit(userId, data);
    onSuccess();
  },
  [userId, onSuccess]
);
```

### useMemo for Expensive Computations
```tsx
const sortedItems = useMemo(
  () => [...items].sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);
```

## State Management

### Local State First
```tsx
// Start simple
const [isOpen, setIsOpen] = useState(false);

// Graduate to useReducer for complex state
const [state, dispatch] = useReducer(cartReducer, initialCart);

// Context for cross-component state
const ThemeContext = createContext<Theme>('light');
```

### Server State (React Query / SWR)
```tsx
const { data, isLoading } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
  staleTime: 5 * 60 * 1000,
});
```

## Performance

### Code Splitting
```tsx
const Dashboard = lazy(() => import('./Dashboard'));

function App() {
  return (
    <Suspense fallback={<Skeleton />}>
      <Dashboard />
    </Suspense>
  );
}
```

### Virtualization for Long Lists
```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });

  return (
    <div ref={parentRef} style={{ overflow: 'auto', height: 400 }}>
      {virtualizer.getVirtualItems().map(row => (
        <div key={row.key} style={{ transform: `translateY(${row.start}px)` }}>
          {items[row.index].name}
        </div>
      ))}
    </div>
  );
}
```

### Error Boundaries
```tsx
class ErrorBoundary extends Component<Props, { hasError: boolean }> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) return this.props.fallback;
    return this.props.children;
  }
}
```

## Checklist

- [ ] Functional components only (no class components for new code)
- [ ] Custom hooks for reusable stateful logic
- [ ] Correct dependency arrays in useEffect/useCallback/useMemo
- [ ] Error boundaries at route level
- [ ] Loading and error states handled for async data
- [ ] Accessibility: ARIA labels, keyboard navigation, focus management
- [ ] Code splitting for route-level components
- [ ] Keys use stable, unique identifiers (not array index)
