<!-- Tokens: ~400 | Lines: 55 | Compatibility: Claude Code 2.1+ -->
# Go Security Rules

Extends `common/security.md` with Go-specific constraints.

## Always

### Input Validation
- Use `validator` package for struct tag validation
- Use `html/template` (not `text/template`) for HTML output
- Validate and sanitize file paths with `filepath.Clean()`
- Use `net/url.Parse()` to validate URLs before use

### Dependencies
- Run `govulncheck ./...` before releases
- Use `go mod verify` to check module integrity
- Pin Go version in `go.mod` with toolchain directive
- Review new dependencies (check Go Report Card, contributors)

### Framework-Specific
```go
// HTTP: Set security headers
func securityHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("Content-Security-Policy", "default-src 'self'")
        next.ServeHTTP(w, r)
    })
}

// SQL: Use parameterized queries
row := db.QueryRowContext(ctx, "SELECT * FROM users WHERE id = $1", userID)

// Crypto: Use crypto/rand, not math/rand
token := make([]byte, 32)
if _, err := crypto_rand.Read(token); err != nil {
    return fmt.Errorf("generating token: %w", err)
}

// File paths: Prevent traversal
cleanPath := filepath.Clean(userInput)
if !strings.HasPrefix(cleanPath, allowedDir) {
    return fmt.Errorf("path traversal attempt: %s", userInput)
}
```

## Never

- Use `math/rand` for security-sensitive randomness — use `crypto/rand`
- Use `text/template` for HTML output — use `html/template`
- Use `fmt.Sprintf` to build SQL queries with user input
- Disable TLS verification (`InsecureSkipVerify: true`) in production
- Use `unsafe` package without security review
- Store secrets in Go source code or embed directives
