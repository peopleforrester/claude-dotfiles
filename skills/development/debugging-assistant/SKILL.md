---
name: debugging-assistant
description: |
  Systematic debugging approach for identifying and fixing bugs. Use when the
  user reports a bug, error, or unexpected behavior. Guides through methodical
  investigation rather than guessing at solutions.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - development
    - debugging
    - troubleshooting
---

# Debugging Assistant

Systematic approach to finding and fixing bugs.

## When to Use

- User reports a bug or error
- Something isn't working as expected
- Error messages or stack traces appear
- Tests are failing unexpectedly

## Debugging Mindset

> "Debugging is like being a detective in a crime movie where you're also the murderer."

Key principles:
- Don't guess - investigate systematically
- Reproduce before fixing
- Understand before changing
- One change at a time

## The Debugging Process

```
1. REPRODUCE - Can you make it happen consistently?
   ↓
2. ISOLATE - Where exactly does it fail?
   ↓
3. UNDERSTAND - Why does it fail?
   ↓
4. FIX - Make the minimal change
   ↓
5. VERIFY - Does the fix work? Any side effects?
   ↓
6. PREVENT - Add test, improve code
```

## Step 1: Reproduce

Before anything else, reproduce the bug consistently.

### Questions to Ask

- What are the exact steps to reproduce?
- What input data triggers the bug?
- Does it happen every time or intermittently?
- What environment? (browser, OS, Node version)

### Create Minimal Reproduction

```typescript
// Reduce to smallest case that shows the bug
const input = { userId: null }; // This specific input
const result = processUser(input); // This call
// Expected: throws error
// Actual: returns undefined, causing crash later
```

## Step 2: Isolate

Narrow down where the problem occurs.

### Binary Search Approach

1. Add log/breakpoint in middle of suspected code
2. Is the bug before or after this point?
3. Repeat, halving the search space

### Useful Commands

```bash
# Git bisect to find breaking commit
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# Git will binary search through commits

# Check if issue exists in specific version
git checkout <commit-hash>
npm test
```

### Logging Strategy

```typescript
console.log('=== DEBUG processUser ===');
console.log('Input:', JSON.stringify(input, null, 2));
console.log('User from DB:', user);
console.log('After transform:', transformed);
console.log('=========================');
```

## Step 3: Understand

Don't fix what you don't understand.

### Read the Error Message

```
TypeError: Cannot read property 'name' of undefined
    at processUser (src/users.ts:42:15)
    at handleRequest (src/api.ts:18:10)
```

This tells you:
- Error type: `TypeError`
- What failed: accessing `.name` on `undefined`
- Where: `src/users.ts` line 42
- Call stack: `handleRequest` → `processUser`

### Common Error Patterns

| Error | Likely Cause |
|-------|--------------|
| `undefined is not a function` | Calling something that doesn't exist |
| `Cannot read property of undefined` | Accessing nested property on null/undefined |
| `Maximum call stack exceeded` | Infinite recursion |
| `ECONNREFUSED` | Service not running |
| `ETIMEDOUT` | Network/service too slow |

### Hypothesis Testing

1. Form hypothesis: "The bug occurs because X"
2. Make prediction: "If X is true, then Y should happen"
3. Test prediction
4. Refine hypothesis based on result

## Step 4: Fix

Make the minimal change that fixes the bug.

### Good Fix

```typescript
// Add null check where the crash occurs
function processUser(input: Input) {
  if (!input.userId) {
    throw new Error('userId is required');
  }
  // ... rest of function
}
```

### Bad Fix

```typescript
// Don't just suppress the error
function processUser(input: Input) {
  try {
    // ... entire function wrapped in try/catch
  } catch (e) {
    return null; // Hides the real problem
  }
}
```

## Step 5: Verify

Ensure the fix works and doesn't break anything else.

```bash
# Run the reproduction case
npm test -- --grep "specific test"

# Run full test suite
npm test

# Manual testing if applicable
```

## Step 6: Prevent

Stop this bug from recurring.

```typescript
// Add test for the bug
it('should throw error when userId is null', () => {
  const input = { userId: null };
  expect(() => processUser(input)).toThrow('userId is required');
});
```

## Debugging Tools

### Browser DevTools

- Console: Errors, logs
- Network: Failed requests, slow responses
- Sources: Breakpoints, step through code
- Performance: Find slow operations

### Node.js

```bash
# Inspect mode
node --inspect src/index.js

# Debug specific test
node --inspect-brk node_modules/.bin/vitest run src/test.ts
```

### VS Code Launch Config

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Tests",
  "program": "${workspaceFolder}/node_modules/.bin/vitest",
  "args": ["run", "--no-coverage"],
  "console": "integratedTerminal"
}
```

## Common Bug Categories

| Category | Check For |
|----------|-----------|
| Null/Undefined | Missing null checks, optional chaining |
| Async | Missing await, race conditions |
| State | Stale state, mutation side effects |
| Types | Type coercion, wrong assumptions |
| Environment | Missing env vars, wrong config |
| Dependencies | Version mismatch, breaking changes |

## When You're Stuck

1. Take a break - fresh eyes help
2. Explain the problem out loud (rubber duck debugging)
3. Simplify - remove code until bug disappears
4. Check recent changes - `git diff`, `git log`
5. Search for the error message
6. Ask for help with specific details
