---
name: golang-testing
description: |
  Comprehensive Go testing patterns. Covers table-driven tests, httptest,
  testcontainers, benchmarks, fuzzing, and race detection.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags: [golang, testing, tdd, benchmarks]
---

# Go Testing Patterns

## Table-Driven Tests

The standard Go testing pattern:

```go
func TestParseAmount(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    float64
        wantErr bool
    }{
        {"valid integer", "100", 100.0, false},
        {"valid decimal", "99.99", 99.99, false},
        {"with currency", "$50.00", 50.0, false},
        {"negative", "-10", -10.0, false},
        {"empty string", "", 0, true},
        {"not a number", "abc", 0, true},
        {"overflow", "9999999999999999999", 0, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseAmount(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("ParseAmount(%q) error = %v, wantErr %v",
                    tt.input, err, tt.wantErr)
            }
            if !tt.wantErr && got != tt.want {
                t.Errorf("ParseAmount(%q) = %v, want %v",
                    tt.input, got, tt.want)
            }
        })
    }
}
```

## HTTP Handler Testing

```go
func TestGetUserHandler(t *testing.T) {
    repo := &mockUserRepo{
        users: map[string]*User{
            "1": {ID: "1", Name: "Alice"},
        },
    }
    handler := NewUserHandler(repo)

    req := httptest.NewRequest("GET", "/users/1", nil)
    rec := httptest.NewRecorder()

    handler.ServeHTTP(rec, req)

    require.Equal(t, http.StatusOK, rec.Code)

    var user User
    err := json.NewDecoder(rec.Body).Decode(&user)
    require.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
}
```

## Subtests for Setup/Teardown

```go
func TestUserService(t *testing.T) {
    db := setupTestDB(t)
    svc := NewUserService(db)

    t.Run("Create", func(t *testing.T) {
        user, err := svc.Create(context.Background(), "Alice", "alice@example.com")
        require.NoError(t, err)
        assert.Equal(t, "Alice", user.Name)
    })

    t.Run("FindByEmail", func(t *testing.T) {
        user, err := svc.FindByEmail(context.Background(), "alice@example.com")
        require.NoError(t, err)
        assert.Equal(t, "Alice", user.Name)
    })

    t.Run("NotFound", func(t *testing.T) {
        _, err := svc.FindByEmail(context.Background(), "missing@example.com")
        assert.ErrorIs(t, err, ErrNotFound)
    })
}
```

## Benchmarks

```go
func BenchmarkParseAmount(b *testing.B) {
    inputs := []string{"100", "99.99", "$50.00", "-10.5"}

    for _, input := range inputs {
        b.Run(input, func(b *testing.B) {
            for i := 0; i < b.N; i++ {
                ParseAmount(input)
            }
        })
    }
}

// Run: go test -bench=. -benchmem ./...
```

## Fuzzing (Go 1.18+)

```go
func FuzzParseAmount(f *testing.F) {
    // Seed corpus
    f.Add("100")
    f.Add("99.99")
    f.Add("$50.00")
    f.Add("")

    f.Fuzz(func(t *testing.T, input string) {
        result, err := ParseAmount(input)
        if err == nil && result < 0 {
            // Verify invariants on successful parse
            t.Errorf("ParseAmount(%q) = %v, expected non-negative", input, result)
        }
    })
}

// Run: go test -fuzz=FuzzParseAmount ./...
```

## Race Detection

```bash
# Always run with -race in CI
go test -race -count=1 ./...
```

## Test Helpers

```go
// testutil/helpers.go
func RequireEqualJSON(t *testing.T, expected, actual string) {
    t.Helper()
    var e, a interface{}
    require.NoError(t, json.Unmarshal([]byte(expected), &e))
    require.NoError(t, json.Unmarshal([]byte(actual), &a))
    assert.Equal(t, e, a)
}
```

## Commands

```bash
go test ./...                    # Run all tests
go test -v ./...                 # Verbose output
go test -race ./...              # Race detection
go test -cover ./...             # Coverage summary
go test -coverprofile=c.out ./... # Coverage profile
go tool cover -html=c.out       # Visual coverage report
go test -bench=. -benchmem ./... # Benchmarks
go test -fuzz=FuzzName ./pkg     # Fuzzing
go test -count=1 ./...           # Disable test caching
```
