---
description: Start TDD workflow for a feature or bug fix. Enforces red-green-refactor cycle with the tdd-guide agent.
---

# /tdd - Test-Driven Development

Invoke the **tdd-guide** agent to enforce strict test-driven development.

## Usage

```
/tdd [feature description or bug reference]
```

## Examples

```
/tdd add user authentication with email/password
/tdd fix cart total calculation when discount applied
/tdd implement search with filtering and pagination
```

## What Happens

1. **Define Test Cases** - List all scenarios before writing anything
2. **RED** - Write a failing test (proves the feature is missing)
3. **GREEN** - Write minimal code to pass the test
4. **REFACTOR** - Improve code while keeping tests green
5. **REPEAT** - Move to next test case
6. **VERIFY** - Check coverage meets 80%+ target

## The Cycle

```
RED → GREEN → REFACTOR → REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass
REFACTOR: Improve code, keep tests passing
REPEAT:   Next test case
```

## When to Use

- Implementing new features
- Fixing bugs (write test that reproduces bug first)
- Building critical business logic
- Adding new functions or components
- Refactoring existing code (write characterization tests first)

## Arguments

`$ARGUMENTS` can include:
- Feature description: `/tdd add user registration`
- Bug reference: `/tdd fix #123`
- Scope: `/tdd implement payment processing for Stripe`
