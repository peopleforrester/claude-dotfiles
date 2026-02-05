<!-- Tokens: ~500 | Lines: 70 | Compatibility: Claude Code 2.1+ -->
# Go Testing Rules

Extends `common/testing.md` with Go-specific testing constraints.

## Always

### Framework
- Use the standard `testing` package for unit tests
- Use `testify/assert` or `testify/require` for cleaner assertions
- Use `httptest` for HTTP handler testing
- Use `testcontainers-go` for integration tests requiring services
- Use `-race` flag to detect data races

### Patterns
```go
// PREFER: Table-driven tests (standard Go pattern)
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid", "user@example.com", false},
        {"no_at", "userexample.com", true},
        {"empty", "", true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("ValidateEmail(%q) err = %v, wantErr %v", tt.email, err, tt.wantErr)
            }
        })
    }
}

// PREFER: httptest for HTTP handlers
func TestGetUser(t *testing.T) {
    handler := NewHandler(mockRepo)
    req := httptest.NewRequest("GET", "/users/1", nil)
    rec := httptest.NewRecorder()
    handler.ServeHTTP(rec, req)
    require.Equal(t, http.StatusOK, rec.Code)
}

// PREFER: Subtests for setup/teardown grouping
func TestDatabase(t *testing.T) {
    db := setupTestDB(t)
    t.Run("Create", func(t *testing.T) { ... })
    t.Run("Read", func(t *testing.T) { ... })
}
```

### Benchmarks
```go
// Include benchmarks for performance-critical code
func BenchmarkParse(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Parse("test-input")
    }
}
```

### Coverage
- Minimum 80% line coverage
- Run with `go test -cover -race ./...`
- Use `go tool cover -html=coverage.out` for visual analysis

## Never

- Use `t.Fatal` in goroutines (use channels to report errors)
- Skip the `-race` flag in CI
- Mock the standard library (wrap it instead)
- Use `time.Sleep` in tests — use channels or `time.After` with context
- Test unexported functions directly — test via the public API
