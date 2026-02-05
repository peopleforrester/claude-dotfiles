---
description: Generate end-to-end tests for critical user flows
---

# /e2e

Generate or update end-to-end tests using Playwright for critical user flows.

## Arguments
- `$ARGUMENTS` — Description of the flow to test, or "audit" to identify missing E2E coverage

## Process

### 1. Flow Analysis
If `$ARGUMENTS` is "audit":
- Scan the application for routes/pages
- Identify critical user flows (auth, CRUD, checkout)
- List flows without E2E coverage
- Prioritize by business impact

If `$ARGUMENTS` describes a flow:
- Understand the flow's steps
- Identify the pages and components involved
- Determine assertions needed

### 2. Test Generation
Delegate to the **e2e-runner** agent to generate tests following:
- Page Object Model pattern
- `data-testid` selectors (suggest additions if missing)
- Proper wait strategies (no `waitForTimeout`)
- Test isolation with state reset

### 3. Verification
- Run the generated tests
- Fix any selector or timing issues
- Verify tests pass consistently (run 3 times)

### 4. Output
```markdown
## E2E Tests Generated

### Files Created/Updated
| File | Flows | Assertions |
|------|-------|------------|
| e2e/auth.spec.ts | Login, Logout | 8 |

### data-testid Additions Needed
| Component | Suggested testid |
|-----------|-----------------|
| LoginButton | login-submit |
| EmailInput | login-email |

### Run Command
```bash
npx playwright test e2e/auth.spec.ts
```
```
