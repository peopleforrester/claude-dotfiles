<!-- Tokens: ~1,300 (target: 1,500) | Lines: 76 | Compatibility: Claude Code 2.1+ -->
# Go Project

A Go application following standard project layout and idioms.

## Stack

- **Language**: Go 1.22+
- **Package Manager**: Go modules
- **Testing**: Built-in testing package
- **Linting**: golangci-lint
- **Formatting**: gofmt / goimports

## Commands

```bash
go run ./cmd/app          # Run application
go build ./cmd/app        # Build binary
go test ./...             # Run all tests
go test -v ./...          # Verbose test output
go test -cover ./...      # Run with coverage
go test -race ./...       # Run with race detector
golangci-lint run         # Run linter
go fmt ./...              # Format code
go mod tidy               # Clean up go.mod
go mod download           # Download dependencies
go generate ./...         # Run go:generate directives
```

## Key Directories

```
cmd/
└── app/
    └── main.go           # Application entry point

internal/
├── config/               # Configuration (not importable)
├── handler/              # HTTP handlers
├── service/              # Business logic
├── repository/           # Data access layer
└── model/                # Domain models

pkg/
└── util/                 # Reusable utilities (importable)

api/
└── openapi.yaml          # API specification
```

## Code Standards

- Use `internal/` for packages not meant for external import
- Accept interfaces, return structs
- Errors are values: check with `if err != nil`
- Context as first parameter: `func Foo(ctx context.Context, ...)`

## Architecture Decisions

- Clean architecture: handler → service → repository
- Dependency injection via constructors
- `context.Context` for cancellation and timeouts
- Structured logging with `slog` (stdlib)

## Gotchas

- `internal/` packages cannot be imported by other modules
- `go test` caches results - use `-count=1` to disable
- Interface satisfaction is implicit - no `implements` keyword
- Zero values are valid: empty string, 0, nil, false

## Dependencies

Key modules in `go.mod`:

- **chi** or **echo**: HTTP router
- **sqlx**: Database operations
- **viper**: Configuration management
- **zap** or **slog**: Structured logging

## Environment Variables

Load with `os.Getenv` or viper:

```
APP_ENV=development
DATABASE_URL=postgres://...
PORT=8080
```

## Testing Strategy

- Unit tests: `*_test.go` in same package
- Table-driven tests with `t.Run()`
- Use `testify/assert` for assertions
- `httptest` for HTTP handler tests
- `-race` flag for concurrency testing

## Error Handling Pattern

```go
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
```

Wrap errors with `%w` for `errors.Is()` and `errors.As()` support.
