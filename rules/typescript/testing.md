<!-- Tokens: ~500 | Lines: 70 | Compatibility: Claude Code 2.1+ -->
# TypeScript Testing Rules

Extends `common/testing.md` with TypeScript-specific testing constraints.

## Always

### Framework
- Use Vitest or Jest for unit/integration tests
- Use Playwright for E2E tests
- Use `@testing-library/react` for React component tests
- Use `msw` (Mock Service Worker) for API mocking

### Patterns
```typescript
// PREFER: Testing behavior, not implementation
test('displays error message when login fails', async () => {
  server.use(
    http.post('/api/login', () => HttpResponse.json({ error: 'Invalid' }, { status: 401 }))
  );
  render(<LoginForm />);
  await userEvent.click(screen.getByRole('button', { name: /sign in/i }));
  expect(screen.getByRole('alert')).toHaveTextContent(/invalid/i);
});

// PREFER: Type-safe mocks
const mockRepo: jest.Mocked<UserRepository> = {
  findById: jest.fn(),
  save: jest.fn(),
};
```

### Coverage
- Minimum 80% line coverage
- 100% coverage on business logic and utilities
- Exclude generated files, types, and config from coverage

### Organization
- Co-locate test files with source (`*.test.ts` or `*.spec.ts`)
- Use `describe` blocks for grouping related tests
- Use `beforeEach` for common setup, avoid `beforeAll` for mutable state

## Never

- Test implementation details (internal state, private methods)
- Use `setTimeout` in tests — use `waitFor` or `findBy` queries
- Share mutable state between tests
- Skip tests without a tracking issue reference
- Use snapshot tests for logic (only for stable UI rendering)
