<!-- Tokens: ~1,450 (target: 1,500) | Lines: 85 | Compatibility: Claude Code 2.1+ -->
# Monorepo

A multi-package repository with shared tooling and coordinated releases.

## Stack

- **Language**: [TypeScript/Python/Rust]
- **Workspace**: [pnpm workspaces/uv workspaces/Cargo workspaces]
- **Task Runner**: [Turborepo/Nx/just]
- **Versioning**: [Changesets/release-please]
- **CI**: GitHub Actions

## Commands

```bash
# Root commands (run from repo root)
pnpm install              # Install all dependencies
pnpm build                # Build all packages
pnpm test                 # Test all packages
pnpm lint                 # Lint all packages
pnpm typecheck            # Type check all packages

# Filtered commands
pnpm --filter @org/api build        # Build specific package
pnpm --filter "./packages/*" test   # Test all packages
pnpm --filter @org/web... build     # Build package and dependencies

# Turborepo (if used)
turbo run build           # Build with caching
turbo run test --affected # Test changed packages only
```

## Key Directories

```
/
├── apps/                 # Deployable applications
│   ├── web/              # Frontend application
│   ├── api/              # Backend API
│   └── docs/             # Documentation site
│
├── packages/             # Shared packages
│   ├── ui/               # Shared UI components
│   ├── config/           # Shared configuration
│   ├── utils/            # Shared utilities
│   └── types/            # Shared TypeScript types
│
├── tooling/              # Development tooling
│   ├── eslint-config/    # Shared ESLint config
│   ├── tsconfig/         # Shared TypeScript configs
│   └── prettier-config/  # Shared Prettier config
│
├── turbo.json            # Turborepo configuration
├── pnpm-workspace.yaml   # Workspace definition
└── package.json          # Root package.json
```

## Code Standards

- Internal packages: `@org/package-name` naming
- Shared configs extend from `tooling/` packages
- Each package has its own `package.json`, `tsconfig.json`
- Root scripts orchestrate cross-package operations

## Architecture Decisions

- Apps consume packages, packages don't import from apps
- Shared types in dedicated `@org/types` package
- Config packages for consistent tooling across packages
- Turborepo for build caching and task orchestration

## Gotchas

- `pnpm` hoisting: check `.npmrc` for `shamefully-hoist` settings
- TypeScript project references for incremental builds
- Circular dependencies: use dependency graphs to detect
- Version sync: keep shared dependencies at same version

## pnpm-workspace.yaml

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'tooling/*'
```

## turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"]
    },
    "lint": {},
    "typecheck": {
      "dependsOn": ["^build"]
    }
  }
}
```

## Internal Package Pattern

```json
// packages/ui/package.json
{
  "name": "@org/ui",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts"
}
```

For internal packages, point directly to source during development.

## Environment Variables

- Apps: `.env` files in each app directory
- Shared: Root `.env` for CI/CD secrets
- Turborepo: Use `globalEnv` and `env` in `turbo.json`

## Release Strategy

Options:
1. **Fixed versioning**: All packages same version
2. **Independent versioning**: Each package versioned separately
3. **Hybrid**: Apps independent, shared packages fixed

Use Changesets for managing versions and changelogs.

## Testing Strategy

- Unit tests: Run per-package
- Integration: Test package interactions
- E2E: Run from app directories
- CI: Use `--affected` to test changed packages only
