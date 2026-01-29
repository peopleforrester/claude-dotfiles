<!-- Tokens: ~1,350 (target: 1,500) | Lines: 78 | Compatibility: Claude Code 2.1+ -->
# CLI Tool

A command-line application with argument parsing, configuration, and user feedback.

## Stack

- **Language**: [TypeScript/Python/Rust/Go]
- **Arg Parser**: [commander/argparse/clap/cobra]
- **Config**: [cosmiconfig/dynaconf/config-rs/viper]
- **Output**: [chalk/rich/colored/color]
- **Distribution**: npm / PyPI / crates.io / Homebrew

## Commands

```bash
[pm] dev              # Run in development mode
[pm] build            # Build executable
[pm] test             # Run tests
[pm] lint             # Lint code
[pm] release          # Build release artifacts
[pm] install-local    # Install locally for testing
```

## Key Directories

```
src/
├── main.ts           # Entry point, CLI setup
├── commands/         # Command implementations
│   ├── init.ts
│   ├── run.ts
│   └── config.ts
├── lib/              # Core logic (framework-agnostic)
├── config/           # Configuration loading
├── utils/
│   ├── output.ts     # Styled output helpers
│   ├── prompts.ts    # Interactive prompts
│   └── fs.ts         # File system utilities
└── types/            # Type definitions

tests/
├── commands/         # Command tests
├── lib/              # Core logic tests
└── fixtures/         # Test files and data
```

## Code Standards

- Exit codes: 0 success, 1 error, 2 user error
- Stderr for errors/warnings, stdout for output
- Support both interactive and piped usage
- Respect `NO_COLOR` and `FORCE_COLOR` env vars

## CLI Design Principles

- Follow POSIX conventions: `-v` short, `--verbose` long
- Provide `--help` for every command and subcommand
- Support `--version` flag
- Use progressive disclosure: simple defaults, advanced flags

## Gotchas

- Test with piped input: `echo "input" | mycli`
- Windows: handle path separators, no ANSI by default
- Large files: stream instead of loading into memory
- Config precedence: CLI flags > env vars > config file > defaults

## Command Pattern

```typescript
// commands/init.ts
export const init = new Command('init')
  .description('Initialize a new project')
  .option('-t, --template <name>', 'Template to use', 'default')
  .option('--force', 'Overwrite existing files')
  .action(async (options) => {
    // Implementation
  });
```

## Output Patterns

```typescript
// Success
console.log(chalk.green('✓'), 'Project initialized');

// Warning
console.error(chalk.yellow('!'), 'Config file not found, using defaults');

// Error
console.error(chalk.red('✗'), 'Failed to connect to database');
process.exit(1);

// Progress
const spinner = ora('Installing dependencies...').start();
// ... work ...
spinner.succeed('Dependencies installed');
```

## Configuration Loading

Priority (highest to lowest):
1. Command-line flags
2. Environment variables
3. Local config (`.myapprc`, `myapp.config.js`)
4. User config (`~/.config/myapp/config.json`)
5. Default values

## Environment Variables

```
MYAPP_CONFIG_PATH=/custom/path
MYAPP_LOG_LEVEL=debug
NO_COLOR=1
```

## Testing Strategy

- Unit: Core library functions
- Integration: Full command execution
- Snapshot: Output formatting consistency
- Test with TTY and non-TTY environments
