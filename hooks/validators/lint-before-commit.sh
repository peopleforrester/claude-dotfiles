#!/usr/bin/env bash
# ABOUTME: Pre-commit hook to run linters before git operations
# ABOUTME: Exits with non-zero status if linting fails

# =============================================================================
# Lint Before Commit Hook
#
# This script runs linters before git commit operations.
# Can be used as a PreToolUse hook or as a git pre-commit hook.
#
# Usage in settings.json:
# {
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Bash(git commit *)",
#         "hooks": [{
#           "type": "command",
#           "command": "~/.claude/hooks/lint-before-commit.sh"
#         }]
#       }
#     ]
#   }
# }
#
# Or install as git hook:
#   cp lint-before-commit.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "Running pre-commit checks..."

# Track if any checks fail
FAILED=0

# =============================================================================
# JavaScript/TypeScript
# =============================================================================

if [ -f "package.json" ]; then
    # Check for ESLint
    if [ -f "node_modules/.bin/eslint" ] || command -v npx &> /dev/null; then
        echo -n "Running ESLint... "
        if npx eslint --max-warnings=0 . 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi

    # Check for TypeScript
    if [ -f "tsconfig.json" ]; then
        echo -n "Running TypeScript... "
        if npx tsc --noEmit 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi

    # Check for Prettier
    if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
        echo -n "Running Prettier... "
        if npx prettier --check . 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${YELLOW}formatting issues${NC}"
            # Don't fail on formatting, just warn
        fi
    fi
fi

# =============================================================================
# Python
# =============================================================================

if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    # Check for Ruff
    if command -v ruff &> /dev/null || [ -f ".venv/bin/ruff" ]; then
        echo -n "Running Ruff... "
        if ruff check . 2>/dev/null || .venv/bin/ruff check . 2>/dev/null; then
            echo -e "${GREEN}passed${NC}"
        else
            echo -e "${RED}failed${NC}"
            FAILED=1
        fi
    fi

    # Check for mypy
    if command -v mypy &> /dev/null || [ -f ".venv/bin/mypy" ]; then
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
# Rust
# =============================================================================

if [ -f "Cargo.toml" ]; then
    echo -n "Running cargo clippy... "
    if cargo clippy --all-targets --all-features -- -D warnings 2>/dev/null; then
        echo -e "${GREEN}passed${NC}"
    else
        echo -e "${RED}failed${NC}"
        FAILED=1
    fi

    echo -n "Running cargo fmt check... "
    if cargo fmt -- --check 2>/dev/null; then
        echo -e "${GREEN}passed${NC}"
    else
        echo -e "${YELLOW}formatting issues${NC}"
    fi
fi

# =============================================================================
# Go
# =============================================================================

if [ -f "go.mod" ]; then
    echo -n "Running go vet... "
    if go vet ./... 2>/dev/null; then
        echo -e "${GREEN}passed${NC}"
    else
        echo -e "${RED}failed${NC}"
        FAILED=1
    fi

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
# Result
# =============================================================================

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. Please fix the issues before committing.${NC}"
    exit 1
fi
