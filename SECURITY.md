# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in claude-dotfiles, please report it
responsibly.

### What to Report

- Security issues in the install scripts
- Configurations that could expose sensitive data
- Hooks that could be exploited
- MCP configurations with security implications

### How to Report

1. **Do not** open a public issue for security vulnerabilities
2. Email the maintainer directly at [your-email@example.com]
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Resolution**: Depends on severity, typically 1-4 weeks

## Security Best Practices

When using claude-dotfiles:

### Credentials

- **Never** commit real API keys or tokens
- Use environment variables for sensitive values
- Review MCP configurations before using

### Permissions

- Start with `conservative` profile if unsure
- Review the `deny` list in settings.json
- Be cautious with `autonomous` profile

### Hooks

- Review hook scripts before enabling
- Be careful with hooks that execute external commands
- Test hooks in a safe environment first

### Install Script

- Review the install script before running
- Use `--dry-run` flag to preview changes
- Keep backups of existing configurations

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Features

claude-dotfiles includes several security features:

1. **Default deny list** - Blocks access to sensitive paths
2. **Sandboxing support** - Container isolation for bash commands
3. **Backup before install** - Preserves existing configs
4. **Validation scripts** - Check configs before use

## Acknowledgments

We appreciate responsible disclosure of security issues.
