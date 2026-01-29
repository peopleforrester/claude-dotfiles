---
name: refactoring-guide
description: |
  Safe refactoring patterns and techniques. Use when the user wants to improve
  code structure, reduce duplication, or make code more maintainable without
  changing behavior. Emphasizes incremental changes with test coverage.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - development
    - refactoring
    - maintenance
---

# Refactoring Guide

Improve code structure safely without changing behavior.

## When to Use

- User asks to "clean up" or "refactor" code
- Code smells detected during review
- Before adding new features to messy code
- Reducing duplication
- Improving readability

## Golden Rules

1. **Never refactor without tests** - Ensure behavior is preserved
2. **Small steps** - One change at a time, run tests after each
3. **No behavior changes** - Refactoring ≠ fixing bugs or adding features
4. **Commit often** - Easy to revert if something breaks

## Refactoring Process

```
1. Ensure tests exist and pass
   ↓
2. Identify the code smell
   ↓
3. Choose appropriate refactoring technique
   ↓
4. Make small change
   ↓
5. Run tests
   ↓
6. Commit if green, revert if red
   ↓
7. Repeat until done
```

## Common Code Smells

### Long Function

**Symptom**: Function > 20-30 lines, multiple responsibilities

**Refactoring**: Extract Method

```typescript
// Before
function processOrder(order: Order) {
  // Validate order (10 lines)
  // Calculate totals (15 lines)
  // Apply discounts (12 lines)
  // Update inventory (8 lines)
  // Send confirmation (10 lines)
}

// After
function processOrder(order: Order) {
  validateOrder(order);
  const totals = calculateTotals(order);
  const finalTotal = applyDiscounts(totals, order.discounts);
  updateInventory(order.items);
  sendConfirmation(order, finalTotal);
}
```

### Duplicate Code

**Symptom**: Similar code in multiple places

**Refactoring**: Extract to shared function

```typescript
// Before
function getUserName(user: User) {
  return `${user.firstName} ${user.lastName}`.trim();
}

function getCustomerName(customer: Customer) {
  return `${customer.firstName} ${customer.lastName}`.trim();
}

// After
function formatFullName(entity: { firstName: string; lastName: string }) {
  return `${entity.firstName} ${entity.lastName}`.trim();
}
```

### Long Parameter List

**Symptom**: Function with > 3-4 parameters

**Refactoring**: Introduce Parameter Object

```typescript
// Before
function createUser(
  name: string,
  email: string,
  age: number,
  address: string,
  phone: string,
  role: string
) { ... }

// After
interface CreateUserInput {
  name: string;
  email: string;
  age: number;
  address: string;
  phone: string;
  role: string;
}

function createUser(input: CreateUserInput) { ... }
```

### Nested Conditionals

**Symptom**: Deep if/else nesting

**Refactoring**: Guard Clauses / Early Returns

```typescript
// Before
function getDiscount(user: User) {
  if (user) {
    if (user.isActive) {
      if (user.isPremium) {
        return 0.2;
      } else {
        return 0.1;
      }
    }
  }
  return 0;
}

// After
function getDiscount(user: User) {
  if (!user) return 0;
  if (!user.isActive) return 0;
  if (user.isPremium) return 0.2;
  return 0.1;
}
```

### Magic Numbers/Strings

**Symptom**: Unexplained literal values in code

**Refactoring**: Extract Constant

```typescript
// Before
if (user.age >= 21) { ... }
if (status === 'PNDG') { ... }

// After
const MINIMUM_AGE = 21;
const ORDER_STATUS = {
  PENDING: 'PNDG',
  COMPLETE: 'CMPL',
} as const;

if (user.age >= MINIMUM_AGE) { ... }
if (status === ORDER_STATUS.PENDING) { ... }
```

### Feature Envy

**Symptom**: Method uses data from another class more than its own

**Refactoring**: Move Method

```typescript
// Before
class Order {
  getCustomerDiscount() {
    if (this.customer.loyaltyYears > 5) {
      return this.customer.baseDiscount * 1.5;
    }
    return this.customer.baseDiscount;
  }
}

// After
class Customer {
  getDiscount() {
    if (this.loyaltyYears > 5) {
      return this.baseDiscount * 1.5;
    }
    return this.baseDiscount;
  }
}
```

## Refactoring Techniques

| Smell | Technique |
|-------|-----------|
| Long function | Extract Method |
| Duplicate code | Extract Function/Class |
| Long parameter list | Parameter Object |
| Nested conditionals | Guard Clauses |
| Magic values | Extract Constant |
| Feature envy | Move Method |
| Large class | Extract Class |
| Primitive obsession | Value Object |
| Switch statements | Replace with Polymorphism |

## Safety Checklist

Before refactoring:
- [ ] Tests exist and pass
- [ ] Understand current behavior
- [ ] Identify specific smell to address

During refactoring:
- [ ] One change at a time
- [ ] Run tests after each change
- [ ] Commit when green

After refactoring:
- [ ] All tests still pass
- [ ] Code is more readable
- [ ] No behavior changed
- [ ] Review the diff

## When NOT to Refactor

- No test coverage exists (write tests first)
- Under tight deadline (technical debt is okay temporarily)
- Code is being deleted soon
- You don't understand the code fully
