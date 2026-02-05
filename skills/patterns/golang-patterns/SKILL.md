---
name: golang-patterns
description: |
  Go 1.22+ best practices, patterns, and idioms. Covers error handling,
  concurrency, interfaces, generics, and standard library patterns.
  Use when writing Go code or reviewing Go patterns.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - golang
    - language
---

# Go Patterns

Modern Go 1.22+ patterns and best practices.

## Error Handling

### Wrap Errors with Context
```go
import "fmt"

func readConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("readConfig %s: %w", path, err)
    }
    // ...
}
```

### Custom Error Types
```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation: %s - %s", e.Field, e.Message)
}

// Check with errors.As
var valErr *ValidationError
if errors.As(err, &valErr) {
    log.Printf("Invalid field: %s", valErr.Field)
}
```

### Sentinel Errors
```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)

// Check with errors.Is
if errors.Is(err, ErrNotFound) {
    http.Error(w, "Not found", http.StatusNotFound)
}
```

## Concurrency

### Structured Concurrency with errgroup
```go
import "golang.org/x/sync/errgroup"

func fetchAll(ctx context.Context, urls []string) ([]Response, error) {
    g, ctx := errgroup.WithContext(ctx)
    results := make([]Response, len(urls))

    for i, url := range urls {
        g.Go(func() error {
            resp, err := fetch(ctx, url)
            if err != nil {
                return err
            }
            results[i] = resp
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}
```

### Context for Cancellation
```go
func longOperation(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            // Do work
        }
    }
}
```

### Channel Patterns
```go
// Fan-out, fan-in
func merge(channels ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup
    for _, ch := range channels {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for v := range ch {
                out <- v
            }
        }()
    }
    go func() {
        wg.Wait()
        close(out)
    }()
    return out
}
```

## Interfaces

### Small Interfaces
```go
// Good: Focused interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// Compose when needed
type ReadWriter interface {
    Reader
    Writer
}
```

### Accept Interfaces, Return Structs
```go
// Good: Function accepts interface
func Process(r io.Reader) error { /* ... */ }

// Good: Function returns concrete type
func NewServer(addr string) *Server { /* ... */ }
```

## Generics (1.18+)

### Type Constraints
```go
type Number interface {
    ~int | ~int64 | ~float64
}

func Sum[T Number](values []T) T {
    var total T
    for _, v := range values {
        total += v
    }
    return total
}
```

## HTTP Patterns

### Middleware Chain
```go
type Middleware func(http.Handler) http.Handler

func Chain(h http.Handler, middlewares ...Middleware) http.Handler {
    for i := len(middlewares) - 1; i >= 0; i-- {
        h = middlewares[i](h)
    }
    return h
}

func LoggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
    })
}
```

## Tooling

| Tool | Purpose | Command |
|------|---------|---------|
| go vet | Static analysis | `go vet ./...` |
| golangci-lint | Meta-linter | `golangci-lint run` |
| go test | Testing | `go test -race -cover ./...` |
| go fmt | Formatting | `gofmt -w .` |

## Checklist

- [ ] Errors wrapped with context (`fmt.Errorf("...: %w", err)`)
- [ ] Context passed to all I/O and long operations
- [ ] Goroutines have proper lifecycle management
- [ ] Interfaces are small (1-3 methods)
- [ ] `go vet` and `golangci-lint` pass
- [ ] Tests use `-race` flag
- [ ] No goroutine leaks (use errgroup or WaitGroup)
