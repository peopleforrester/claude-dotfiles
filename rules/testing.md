<!-- Tokens: ~750 | Lines: 100 | Compatibility: Claude Code 2.1+ -->
# Testing Rules

Mandatory testing constraints for all projects. Every feature must be tested,
every bug fix must include a regression test.

## Coverage Requirements

| Code Category | Minimum Coverage | Rationale |
|--------------|-----------------|-----------|
| Business logic | 80% line coverage | Core value - must be reliable |
| Security-critical | 100% branch coverage | Vulnerabilities are costly |
| Utility functions | 90% line coverage | Widely reused, high leverage |
| UI components | 70% line coverage | Visual testing supplements |
| Configuration/glue | 50% line coverage | Low complexity |

## Test Types Required

Every project must include all three levels:

### Unit Tests
- Test individual functions, classes, and components in isolation
- Mock external dependencies (APIs, databases, filesystem)
- Fast execution (< 1 second per test)
- Run on every commit

### Integration Tests
- Test interactions between components (API + database, service + cache)
- Use test databases or containers
- Verify data flows correctly across boundaries
- Run before merge

### End-to-End Tests
- Test critical user journeys through the full stack
- Use browser automation (Playwright, Cypress) for web apps
- Cover the 3-5 most important user workflows
- Run before release

## TDD Workflow (Red-Green-Refactor)

### Mandatory Cycle
```
1. RED:      Write a test that fails (proves the feature is missing)
2. GREEN:    Write the minimum code to make the test pass
3. REFACTOR: Improve the code while keeping tests green
4. REPEAT:   Move to the next test case
```

### Enforcement
- No implementation code before a failing test exists
- Tests must fail for the correct reason (not syntax errors)
- Write only enough code to pass the current test
- Refactor only when all tests are green
- Run the full test suite after every refactor

## Test Quality Standards

### Always
- One assertion concept per test (test one behavior)
- Tests are independent (no shared mutable state between tests)
- Tests run in any order with the same result
- Test names describe the behavior being verified
- Use Arrange-Act-Assert (AAA) or Given-When-Then pattern

### Pattern
```typescript
describe('calculateDiscount', () => {
  it('should apply percentage discount to order total', () => {
    // Arrange
    const total = 100;
    const discountPercent = 10;

    // Act
    const result = calculateDiscount(total, discountPercent);

    // Assert
    expect(result).toBe(90);
  });
});
```

### Never
- Tests that depend on execution order
- Tests that modify global or shared state
- Tests that require network access or real external services
- Tests that use `sleep()` or arbitrary waits (use polling/events)
- Tests that test private implementation details
- Skipped tests left in the codebase (`.skip`, `@pytest.mark.skip`)

## Before Pull Request

- [ ] All tests pass locally
- [ ] Coverage threshold is met (80%+ overall)
- [ ] New code has corresponding tests
- [ ] Bug fixes include regression tests
- [ ] No skipped or disabled tests
- [ ] Test names clearly describe expected behavior
- [ ] Flaky tests have been investigated and fixed

## Troubleshooting Test Failures

1. Read the full error message and stack trace
2. Verify test isolation (no shared state leaking)
3. Check that mocks match current interfaces
4. Fix the implementation, not the test (unless the test is wrong)
5. If a test is flaky, investigate the root cause immediately
