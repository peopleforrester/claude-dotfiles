---
name: rust-patterns
description: |
  Rust best practices, patterns, and idioms. Covers ownership, error handling
  with Result/Option, traits, lifetimes, and async Rust. Use when writing
  Rust code or reviewing Rust patterns.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - rust
    - language
---

# Rust Patterns

Modern Rust patterns and best practices.

## Error Handling

### Custom Error Types with thiserror
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Database error")]
    Database(#[from] sqlx::Error),

    #[error("IO error")]
    Io(#[from] std::io::Error),
}
```

### Propagation with ?
```rust
fn read_config(path: &str) -> Result<Config, AppError> {
    let content = std::fs::read_to_string(path)?;  // Auto-converts io::Error
    let config: Config = serde_json::from_str(&content)
        .map_err(|e| AppError::NotFound(format!("Invalid config: {e}")))?;
    Ok(config)
}
```

### Option Combinators
```rust
fn find_user(id: &str) -> Option<User> {
    users.iter()
        .find(|u| u.id == id)
        .filter(|u| u.is_active)
        .map(|u| u.clone())
}

// Chain with unwrap_or, unwrap_or_else, unwrap_or_default
let name = user.name.as_deref().unwrap_or("Anonymous");
```

## Ownership and Borrowing

### Prefer Borrowing
```rust
// Good: Borrows data, doesn't take ownership
fn process(data: &[u8]) -> Result<Output, Error> { /* ... */ }

// Good: Mutable borrow when needed
fn update(config: &mut Config) { /* ... */ }

// Take ownership only when necessary (storing, sending to thread)
fn spawn_worker(data: Vec<u8>) { /* ... */ }
```

### Builder Pattern
```rust
pub struct ServerBuilder {
    addr: String,
    port: u16,
    max_connections: Option<usize>,
}

impl ServerBuilder {
    pub fn new(addr: impl Into<String>) -> Self {
        Self {
            addr: addr.into(),
            port: 8080,
            max_connections: None,
        }
    }

    pub fn port(mut self, port: u16) -> Self {
        self.port = port;
        self
    }

    pub fn max_connections(mut self, max: usize) -> Self {
        self.max_connections = Some(max);
        self
    }

    pub fn build(self) -> Server {
        Server { /* ... */ }
    }
}

// Usage: Server::builder("localhost").port(3000).build()
```

## Traits

### Define Behavior, Not Data
```rust
pub trait Repository {
    type Error;

    fn find_by_id(&self, id: &str) -> Result<Option<User>, Self::Error>;
    fn save(&self, user: &User) -> Result<(), Self::Error>;
    fn delete(&self, id: &str) -> Result<bool, Self::Error>;
}
```

### Blanket Implementations
```rust
// Implement for all types that satisfy bounds
impl<T: Display + Debug> Loggable for T {
    fn log(&self) {
        println!("[LOG] {self}");
    }
}
```

## Async Rust

### Tokio Patterns
```rust
use tokio::task::JoinSet;

async fn fetch_all(urls: Vec<String>) -> Vec<Result<Response, Error>> {
    let mut set = JoinSet::new();

    for url in urls {
        set.spawn(async move {
            reqwest::get(&url).await?.text().await
        });
    }

    let mut results = Vec::new();
    while let Some(result) = set.join_next().await {
        results.push(result.unwrap());
    }
    results
}
```

### Graceful Shutdown
```rust
use tokio::signal;

async fn run_server() -> Result<(), Error> {
    let server = start_server().await?;

    signal::ctrl_c().await?;
    println!("Shutting down...");

    server.shutdown().await;
    Ok(())
}
```

## Tooling

| Tool | Purpose | Command |
|------|---------|---------|
| cargo check | Type checking | `cargo check` |
| cargo clippy | Linting | `cargo clippy -- -D warnings` |
| cargo fmt | Formatting | `cargo fmt -- --check` |
| cargo test | Testing | `cargo test` |
| cargo audit | Security | `cargo audit` |

## Checklist

- [ ] `clippy` passes with no warnings
- [ ] Error types defined with `thiserror`
- [ ] `?` operator for error propagation
- [ ] Prefer borrowing over ownership transfer
- [ ] `Clone` only when necessary
- [ ] `Send + Sync` bounds for async types
- [ ] No `unwrap()` in library code (use `?` or `expect`)
- [ ] Builder pattern for types with many options
