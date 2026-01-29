<!-- Tokens: ~1,400 (target: 1,500) | Lines: 82 | Compatibility: Claude Code 2.1+ -->
# Library / Package

A reusable library published to npm / PyPI / crates.io with docs and semver.

## Stack

- **Language**: [TypeScript/Python/Rust]
- **Registry**: [npm/PyPI/crates.io]
- **Bundler**: [tsup/hatch/cargo]
- **Docs**: [TypeDoc/Sphinx/rustdoc]
- **Testing**: [Vitest/pytest/cargo test]

## Commands

```bash
[pm] dev              # Development watch mode
[pm] build            # Build for distribution
[pm] test             # Run tests
[pm] test:coverage    # Tests with coverage
[pm] lint             # Lint code
[pm] docs             # Generate documentation
[pm] docs:serve       # Serve docs locally
[pm] release          # Publish to registry
[pm] changeset        # Create changeset for versioning
```

## Key Directories

```
src/
├── index.ts          # Public API exports
├── core/             # Core implementation
├── utils/            # Internal utilities
└── types.ts          # Public type definitions

tests/
├── unit/             # Unit tests
└── integration/      # Integration tests

docs/
├── api/              # Generated API docs
└── guides/           # Usage guides

examples/
└── basic/            # Example usage projects
```

## Code Standards

- Export only intentional public API from index
- Deprecate before removing (minimum one major version)
- Document all public functions and types
- No side effects on import

## API Design Principles

- Minimal public API surface
- Sensible defaults, explicit options
- Immutable by default
- Throw errors early with helpful messages

## Gotchas

- `peerDependencies` for framework integrations
- Tree-shaking: use named exports, avoid barrel files with side effects
- Bundle size: check with `bundlephobia` before release
- Breaking changes: follow semver strictly

## Versioning (Semver)

- **MAJOR**: Breaking API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

Use changesets or conventional commits for automated versioning.

## Package.json Essentials

```json
{
  "name": "my-library",
  "version": "1.0.0",
  "main": "./dist/index.cjs",
  "module": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.cjs",
      "types": "./dist/index.d.ts"
    }
  },
  "files": ["dist"],
  "sideEffects": false
}
```

## Documentation Pattern

```typescript
/**
 * Formats a date according to the specified pattern.
 *
 * @param date - The date to format
 * @param pattern - Format pattern (default: 'YYYY-MM-DD')
 * @returns Formatted date string
 *
 * @example
 * ```ts
 * formatDate(new Date(), 'MM/DD/YYYY')
 * // => '01/15/2026'
 * ```
 *
 * @since 1.0.0
 */
export function formatDate(date: Date, pattern = 'YYYY-MM-DD'): string {
  // ...
}
```

## Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version bumped
- [ ] Git tag created
- [ ] Published to registry
- [ ] GitHub release created

## Testing Strategy

- Unit: All public functions
- Edge cases: Empty inputs, large inputs, invalid inputs
- Types: Ensure types are correctly exported
- Examples: Test example code compiles and runs
