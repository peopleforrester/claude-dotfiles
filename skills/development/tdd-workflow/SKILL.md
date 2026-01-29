---
name: tdd-workflow
description: |
  Test-driven development workflow for implementing new features and fixing bugs.
  Use when the user mentions TDD, "write tests first", "red-green-refactor",
  or when implementing features that need comprehensive test coverage.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - development
    - testing
    - workflow
---

# Test-Driven Development Workflow

A systematic approach to writing code guided by tests.

## When to Use

- User explicitly requests TDD approach
- Implementing new features with clear requirements
- Fixing bugs (write failing test first)
- Refactoring existing code safely
- When high test coverage is required

## The TDD Cycle

```
┌─────────────────────────────────────────┐
│                                         │
│   1. RED: Write a failing test          │
│      ↓                                  │
│   2. GREEN: Write minimal code to pass  │
│      ↓                                  │
│   3. REFACTOR: Improve while green      │
│      ↓                                  │
│   (repeat)                              │
│                                         │
└─────────────────────────────────────────┘
```

## Instructions

### Step 1: Understand Requirements

Before writing any code:

1. Clarify the expected behavior with the user
2. Identify edge cases and error conditions
3. Break down into small, testable units

### Step 2: Write the First Failing Test

```typescript
// Start with the simplest case
describe('calculateTotal', () => {
  it('should return 0 for empty cart', () => {
    const result = calculateTotal([]);
    expect(result).toBe(0);
  });
});
```

Run the test - it should fail (RED).

### Step 3: Write Minimal Code to Pass

```typescript
function calculateTotal(items: CartItem[]): number {
  return 0; // Simplest implementation that passes
}
```

Run the test - it should pass (GREEN).

### Step 4: Add Next Test Case

```typescript
it('should sum item prices', () => {
  const items = [{ price: 10 }, { price: 20 }];
  expect(calculateTotal(items)).toBe(30);
});
```

This test fails, so update implementation.

### Step 5: Iterate

Continue the cycle:
- Add test for edge case → implement
- Add test for error handling → implement
- Add test for complex scenario → implement

### Step 6: Refactor

Once all tests pass, refactor:
- Extract helper functions
- Improve naming
- Reduce duplication
- Optimize if needed

**Critical**: Run tests after each change to ensure they still pass.

## Test Quality Checklist

- [ ] Tests are independent (no shared mutable state)
- [ ] Test names describe the behavior being tested
- [ ] Each test verifies one specific behavior
- [ ] Edge cases are covered (empty, null, boundary values)
- [ ] Error conditions are tested
- [ ] Tests run fast (mock external dependencies)

## Common Test Patterns

### Arrange-Act-Assert

```typescript
it('should apply discount to total', () => {
  // Arrange
  const items = [{ price: 100 }];
  const discount = 0.1;

  // Act
  const result = calculateTotal(items, discount);

  // Assert
  expect(result).toBe(90);
});
```

### Testing Errors

```typescript
it('should throw on negative price', () => {
  const items = [{ price: -10 }];
  expect(() => calculateTotal(items)).toThrow('Price cannot be negative');
});
```

### Testing Async Code

```typescript
it('should fetch user data', async () => {
  const user = await fetchUser(123);
  expect(user.name).toBe('John');
});
```

## Examples

### Bug Fix with TDD

1. Write a test that reproduces the bug
2. Verify test fails
3. Fix the bug
4. Verify test passes
5. Ensure no other tests broke

### New Feature with TDD

1. List all behaviors the feature needs
2. Write test for simplest behavior
3. Implement
4. Write test for next behavior
5. Implement
6. Continue until feature complete

## Anti-Patterns to Avoid

- ❌ Writing implementation before tests
- ❌ Writing all tests at once before any implementation
- ❌ Tests that test implementation details, not behavior
- ❌ Skipping the refactor step
- ❌ Tests that depend on execution order
