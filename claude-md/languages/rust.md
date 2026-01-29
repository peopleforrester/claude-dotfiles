<!-- Tokens: ~1,300 (target: 1,500) | Lines: 76 | Compatibility: Claude Code 2.1+ -->
# Rust Project

A Rust application with idiomatic patterns and safe concurrency.

## Stack

- **Language**: Rust (stable toolchain)
- **Package Manager**: Cargo
- **Testing**: Built-in test framework
- **Linting**: Clippy
- **Formatting**: rustfmt

## Commands

```bash
cargo build              # Debug build
cargo build --release    # Release build
cargo run                # Build and run
cargo test               # Run all tests
cargo test -- --nocapture  # Tests with stdout
cargo clippy             # Lint with clippy
cargo fmt                # Format code
cargo fmt -- --check     # Check formatting
cargo doc --open         # Generate and open docs
cargo check              # Fast type checking
cargo update             # Update dependencies
```

## Key Directories

```
src/
├── main.rs           # Binary entry point
├── lib.rs            # Library root (if dual crate)
├── config.rs         # Configuration handling
├── error.rs          # Custom error types
├── models/           # Data structures
└── services/         # Business logic

tests/
├── integration/      # Integration tests
└── common/           # Shared test utilities
    └── mod.rs
```

## Code Standards

- Use `Result<T, E>` for fallible operations, not panics
- Derive common traits: `Debug`, `Clone`, `PartialEq`
- Prefer `&str` over `String` in function parameters
- Use `thiserror` for library errors, `anyhow` for applications

## Architecture Decisions

- `serde` for serialization/deserialization
- `tokio` runtime for async operations
- Builder pattern for complex struct construction
- Type-state pattern for compile-time state machines

## Gotchas

- `cargo build` output in `target/debug/`, release in `target/release/`
- Integration tests go in `tests/` directory, not `src/`
- `#[cfg(test)]` modules are stripped from release builds
- Lifetimes: start with owned types, add references for optimization

## Dependencies

Key crates in `Cargo.toml`:

- **tokio**: Async runtime (`features = ["full"]`)
- **serde**: Serialization (`features = ["derive"]`)
- **thiserror**: Error derive macros
- **tracing**: Structured logging

## Environment Variables

Load with `dotenvy` or `config` crate:

```
RUST_LOG=debug
DATABASE_URL=postgres://...
```

## Testing Strategy

- Unit tests: `#[cfg(test)]` module in same file
- Integration tests: `tests/` directory
- Doc tests: Examples in doc comments
- Use `#[should_panic]` for expected panics
- `mockall` crate for mocking traits

## Workspace Structure (Multi-crate)

```toml
# Cargo.toml
[workspace]
members = ["crates/*"]
```
