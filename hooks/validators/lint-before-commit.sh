#!/usr/bin/env bash
# ABOUTME: Pre-commit hook to run linters before git operations
# ABOUTME: Exits with non-zero status if linting fails

# =============================================================================
# Lint Before Commit Hook for Claude Code
# =============================================================================
#
# PURPOSE:
# This script runs language-appropriate linters before allowing a git commit.
# It ensures code quality by catching issues early in the development process.
#
# WHY LINT BEFORE COMMIT?
# - Catches bugs, style issues, and potential problems early
# - Maintains consistent code quality across the team
# - Prevents broken code from entering version control
# - Saves time by catching issues before code review
#
# HOW IT WORKS:
# 1. Detects which programming languages are used in the project
# 2. Runs appropriate linters for each detected language
# 3. Reports results with colored output
# 4. Returns non-zero exit code if any linter fails
#
# SUPPORTED LANGUAGES:
# - JavaScript/TypeScript: ESLint, TypeScript compiler, Prettier
# - Python: Ruff, mypy
# - Rust: cargo clippy, cargo fmt
# - Go: go vet, golangci-lint
#
# TWO USAGE MODES:
#
# 1. CLAUDE CODE HOOK (PreToolUse):
#    Runs when Claude attempts to commit code.
#
#    Configuration in settings.json:
#    {
#      "hooks": {
#        "PreToolUse": [
#          {
#            "matcher": "Bash(git commit *)",
#            "hooks": [{
#              "type": "command",
#              "command": "~/.claude/hooks/lint-before-commit.sh"
#            }]
#          }
#        ]
#      }
#    }
#
# 2. GIT PRE-COMMIT HOOK:
#    Runs automatically before any git commit.
#
#    Installation:
#      cp lint-before-commit.sh .git/hooks/pre-commit
#      chmod +x .git/hooks/pre-commit
#
# MATCHER EXPLAINED:
# "Bash(git commit *)": Pattern to match git commit commands
# - Bash(...): Matches Bash tool calls
# - git commit *: Glob pattern matching "git commit" followed by anything
# - This triggers for: git commit -m "message", git commit --amend, etc.
#
# EXIT CODES:
#   0 - All checks passed
#   1 - One or more checks failed
# =============================================================================

# =============================================================================
# STRICT MODE
# =============================================================================
# set -e: Exit immediately if any command fails.
# This is essential for a validation script - we want to stop on first failure.
#
# NOTE: We DON'T use -u (undefined variable check) here because we use || true
# patterns that might reference undefined variables in some edge cases.
# =============================================================================
set -e

# =============================================================================
# TERMINAL COLOR DEFINITIONS
# =============================================================================
# ANSI escape codes for colorized output.
# These make it easy to visually distinguish passed/failed/warning status.
#
# Format: \033[<code>m where:
# - 0;31 = Red (failed)
# - 0;32 = Green (passed)
# - 0;33 = Yellow (warning/info)
# - 0 = Reset (no color)
# =============================================================================
RED='\033[0;31m'      # Failed checks
GREEN='\033[0;32m'    # Passed checks
YELLOW='\033[0;33m'   # Warnings (non-fatal)
NC='\033[0m'          # No Color (reset)

# =============================================================================
# SCRIPT INITIALIZATION
# =============================================================================
echo "Running pre-commit checks..."

# Track overall success/failure state
# We use this to allow all checks to run even if some fail,
# then report the final result at the end.
FAILED=0

# =============================================================================
# JAVASCRIPT / TYPESCRIPT CHECKS
# =============================================================================
# Detects Node.js projects by looking for package.json.
# Runs applicable linters based on project configuration.
#
# PROJECT DETECTION:
# - package.json: Indicates a Node.js/npm project
# - tsconfig.json: Indicates TypeScript is used
# - .prettierrc: Indicates Prettier is configured
# =============================================================================

if [ -f "package.json" ]; then
    # =========================================================================
    # ESLINT
    # =========================================================================
    # ESLint is the standard JavaScript/TypeScript linter.
    # It catches bugs, enforces code style, and suggests best practices.
    #
    # Detection: Check for local installation OR npx availability
    # - node_modules/.bin/eslint: Local project installation
    # - npx eslint: npm's package runner (downloads if needed)
    #
    # --max-warnings=0: Treat warnings as errors
    # This enforces zero-tolerance for code quality issues.
    # =========================================================================
    if [ -f "node_modules/.bin/eslint" ] || command -v npx &> /dev/null; then
        # echo -n: Print without newline (result will follow on same line)
        echo -n "Running ESLint... "

        # Run ESLint, suppress output (we only care about exit code)
        if npx eslint --max-warnings=0 . 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi

    # =========================================================================
    # TYPESCRIPT COMPILER
    # =========================================================================
    # The TypeScript compiler (tsc) with --noEmit flag performs type checking
    # without generating output files. This catches type errors.
    #
    # --noEmit: Only check types, don't produce .js files
    # =========================================================================
    if [ -f "tsconfig.json" ]; then
        echo -n "Running TypeScript... "

        if npx tsc --noEmit 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi

    # =========================================================================
    # PRETTIER (Formatting Check)
    # =========================================================================
    # Prettier is an opinionated code formatter. We only CHECK formatting here
    # (--check), not automatically fix it.
    #
    # NOTE: Formatting issues are shown as warnings (yellow), not failures.
    # This is intentional - formatting is less critical than linting errors,
    # and auto-formatting can fix these issues.
    #
    # Detection: Check for various Prettier config files
    # =========================================================================
    if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
        echo -n "Running Prettier... "

        if npx prettier --check . 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            # Yellow warning instead of red failure
            echo -e "${YELLOW}formatting issues${NC}"
            # Don't fail on formatting, just warn
            # User can run: npx prettier --write . to fix
        fi
    fi
fi

# =============================================================================
# PYTHON CHECKS
# =============================================================================
# Detects Python projects and runs appropriate linters.
#
# PROJECT DETECTION:
# - pyproject.toml: Modern Python packaging (PEP 517/518)
# - setup.py: Traditional Python packaging
# - requirements.txt: pip dependencies file
# =============================================================================

if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    # =========================================================================
    # RUFF
    # =========================================================================
    # Ruff is an extremely fast Python linter written in Rust.
    # It's designed to replace flake8, isort, and many other tools.
    #
    # Detection: Check system PATH or virtual environment
    # - ruff: Global installation
    # - .venv/bin/ruff: Virtual environment installation
    # =========================================================================
    if command -v ruff &> /dev/null || [ -f ".venv/bin/ruff" ]; then
        echo -n "Running Ruff... "

        # Try system ruff first, then venv ruff
        if ruff check . 2>/dev/null || .venv/bin/ruff check . 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi

    # =========================================================================
    # MYPY (Type Checking)
    # =========================================================================
    # mypy is the static type checker for Python. It validates type hints
    # and catches type-related bugs before runtime.
    #
    # Only runs if mypy is installed AND configured (mypy.ini or pyproject.toml)
    # Running mypy without configuration on an untyped project produces too
    # many false positives.
    # =========================================================================
    if command -v mypy &> /dev/null || [ -f ".venv/bin/mypy" ]; then
        # Only run if mypy is configured
        if [ -f "mypy.ini" ] || [ -f "pyproject.toml" ]; then
            echo -n "Running mypy... "

            if mypy . 2>/dev/null || .venv/bin/mypy . 2>/dev/null; then
                echo -e "${GREEN}passed${NC}"
            else
                echo -e "${RED}failed${NC}"
                FAILED=1
            fi
        fi
    fi
fi

# =============================================================================
# RUST CHECKS
# =============================================================================
# Detects Rust projects by looking for Cargo.toml.
# Runs Clippy (linter) and rustfmt (formatter).
#
# Cargo.toml: Rust package manifest file
# =============================================================================

if [ -f "Cargo.toml" ]; then
    # =========================================================================
    # CARGO CLIPPY
    # =========================================================================
    # Clippy is Rust's official linter. It catches common mistakes and
    # suggests more idiomatic Rust code.
    #
    # --all-targets: Check all targets (tests, benches, examples)
    # --all-features: Enable all feature flags
    # -- -D warnings: Treat all warnings as errors (deny warnings)
    # =========================================================================
    echo -n "Running cargo clippy... "

    if cargo clippy --all-targets --all-features -- -D warnings 2>/dev/null; then
        echo -e "${GREEN}passed${NC}"
    else
        echo -e "${RED}failed${NC}"
        FAILED=1
    fi

    # =========================================================================
    # CARGO FMT (Formatting Check)
    # =========================================================================
    # rustfmt is the official Rust code formatter.
    # --check: Only check formatting, don't modify files
    #
    # Like Prettier, formatting issues are warnings, not failures.
    # =========================================================================
    echo -n "Running cargo fmt check... "

    if cargo fmt -- --check 2>/dev/null; then
        echo -e "${GREEN}passed${NC}"
    else
        # Warning instead of failure
        echo -e "${YELLOW}formatting issues${NC}"
        # User can run: cargo fmt to fix
    fi
fi

# =============================================================================
# GO CHECKS
# =============================================================================
# Detects Go projects by looking for go.mod.
# Runs go vet (built-in) and golangci-lint (if installed).
#
# go.mod: Go module definition file (indicates a Go module project)
# =============================================================================

if [ -f "go.mod" ]; then
    # =========================================================================
    # GO VET
    # =========================================================================
    # go vet is Go's built-in static analysis tool.
    # It catches suspicious constructs that might be bugs.
    #
    # ./...: Check all packages in the module
    # =========================================================================
    echo -n "Running go vet... "

    if go vet ./... 2>/dev/null; then
        echo -e "${GREEN}passed${NC}"
    else
        echo -e "${RED}failed${NC}"
        FAILED=1
    fi

    # =========================================================================
    # GOLANGCI-LINT
    # =========================================================================
    # golangci-lint is a meta-linter that runs many Go linters in parallel.
    # It's the de facto standard for Go projects.
    #
    # Only runs if installed (it's not part of the Go distribution).
    # Installation: https://golangci-lint.run/usage/install/
    # =========================================================================
    if command -v golangci-lint &> /dev/null; then
        echo -n "Running golangci-lint... "

        if golangci-lint run 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi
fi

# =============================================================================
# FINAL RESULT
# =============================================================================
# Report the overall result and exit with appropriate code.
# Exit code 0 means success (allow commit), 1 means failure (block commit).
# =============================================================================
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. Please fix the issues before committing.${NC}"
    exit 1
fi
