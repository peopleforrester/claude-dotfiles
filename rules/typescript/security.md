<!-- Tokens: ~400 | Lines: 55 | Compatibility: Claude Code 2.1+ -->
# TypeScript Security Rules

Extends `common/security.md` with TypeScript/Node.js-specific constraints.

## Always

### Input Validation
- Validate all API inputs with Zod, io-ts, or similar runtime validators
- Sanitize HTML output with DOMPurify or equivalent
- Use `encodeURIComponent()` for URL parameters
- Validate environment variables at startup, fail fast on missing required values

### Dependencies
- Run `npm audit` before every release
- Pin major versions in production dependencies
- Review new dependencies for typosquatting (check npm weekly downloads, repo stars)
- Use `--ignore-scripts` for untrusted packages during install

### Framework-Specific
```typescript
// React: Avoid dangerouslySetInnerHTML
// If unavoidable, always sanitize first
const clean = DOMPurify.sanitize(userContent);

// Express: Use helmet for security headers
app.use(helmet());

// Next.js: Use server actions with validation
export async function createUser(formData: FormData) {
  const parsed = UserSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) throw new Error('Invalid input');
}

// Environment: Validate at startup
const env = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
}).parse(process.env);
```

## Never

- Use `eval()`, `new Function()`, or `vm.runInNewContext()` with user input
- Interpolate user input into `child_process.exec()` — use `execFile()` with args array
- Store JWTs in localStorage — use httpOnly cookies
- Use `*` CORS origins in production
- Disable CSP headers
