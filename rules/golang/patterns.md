<!-- Tokens: ~500 | Lines: 70 | Compatibility: Claude Code 2.1+ -->
# Go Design Patterns

Extends `common/patterns.md` with Go-specific patterns.

## Functional Options Pattern
```go
type ServerOption func(*Server)

func WithPort(port int) ServerOption {
    return func(s *Server) { s.port = port }
}

func WithTimeout(d time.Duration) ServerOption {
    return func(s *Server) { s.timeout = d }
}

func NewServer(opts ...ServerOption) *Server {
    s := &Server{port: 8080, timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage: srv := NewServer(WithPort(9090), WithTimeout(60*time.Second))
```

## Small Interface Pattern
```go
// Define interfaces where they are used, not where they are implemented
type UserFinder interface {
    FindByID(ctx context.Context, id string) (*User, error)
}

type UserCreator interface {
    Create(ctx context.Context, input CreateUserInput) (*User, error)
}

// Compose interfaces only when needed
type UserStore interface {
    UserFinder
    UserCreator
}
```

## Constructor Injection
```go
type Service struct {
    repo   UserRepository
    cache  Cache
    logger *slog.Logger
}

func NewService(repo UserRepository, cache Cache, logger *slog.Logger) *Service {
    return &Service{repo: repo, cache: cache, logger: logger}
}
```

## Error Wrapping Pattern
```go
func (s *Service) GetUser(ctx context.Context, id string) (*User, error) {
    user, err := s.repo.FindByID(ctx, id)
    if err != nil {
        if errors.Is(err, ErrNotFound) {
            return nil, fmt.Errorf("user %s: %w", id, ErrNotFound)
        }
        return nil, fmt.Errorf("fetching user %s: %w", id, err)
    }
    return user, nil
}
```

## Middleware Pattern
```go
func LoggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            next.ServeHTTP(w, r)
            logger.Info("request",
                "method", r.Method,
                "path", r.URL.Path,
                "duration", time.Since(start),
            )
        })
    }
}
```

## References
- See `skills/patterns/golang-patterns/SKILL.md` for comprehensive patterns
- See `skills/development/golang-testing/SKILL.md` for testing patterns
