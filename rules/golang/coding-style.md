<!-- Tokens: ~600 | Lines: 80 | Compatibility: Claude Code 2.1+ -->
# Go Coding Style Rules

Extends `common/coding-style.md` with Go-specific constraints.

## Always

### Error Handling
- Check every error return value — never discard with `_`
- Wrap errors with context using `fmt.Errorf("doing X: %w", err)`
- Use sentinel errors for expected conditions (`var ErrNotFound = errors.New(...)`)
- Use custom error types when callers need to inspect error details
- Handle deferred close errors (`defer func() { if err := f.Close(); ... }()`)

### Patterns
```go
// PREFER: Accept interfaces, return structs
func NewService(repo UserRepository) *Service {
    return &Service{repo: repo}
}

// PREFER: Small, focused interfaces
type Reader interface {
    Read(ctx context.Context, id string) (*Item, error)
}

// PREFER: Table-driven tests
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {"valid", "42", 42, false},
        {"empty", "", 0, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("Parse(%q) err = %v, wantErr %v", tt.input, err, tt.wantErr)
            }
            if got != tt.want {
                t.Errorf("Parse(%q) = %v, want %v", tt.input, got, tt.want)
            }
        })
    }
}

// PREFER: Context for cancellation and timeouts
func FetchData(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    // ...
}
```

### Concurrency
- Use `errgroup` for managed goroutine coordination
- Use `context.Context` for cancellation propagation
- Use `sync.Mutex` or channels — pick one pattern per data structure
- Use `sync.Once` for lazy initialization

### Project Layout
- Follow the standard Go project layout
- Keep packages small and focused
- Use internal/ for private packages
- Run `gofmt` and `goimports` on every save

## Never

- Discard errors with `_ = someFunc()`
- Use `panic()` for expected error conditions (only for unrecoverable states)
- Use `init()` functions for complex initialization
- Export unexported types via type aliases
- Use global mutable state — pass dependencies explicitly
- Use `interface{}` when generics (Go 1.18+) work
