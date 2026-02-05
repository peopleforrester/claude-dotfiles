#!/usr/bin/env bash
# ABOUTME: Detects the package manager for the current project.
# ABOUTME: Priority: env var > project config > package.json > lock files > global config > fallback.

set -euo pipefail

detect_pm() {
    # 1. Environment variable
    if [[ -n "${CLAUDE_PACKAGE_MANAGER:-}" ]]; then
        echo "$CLAUDE_PACKAGE_MANAGER"
        return
    fi

    # 2. Project config (.claude/package-manager.json)
    if [[ -f ".claude/package-manager.json" ]]; then
        local pm
        pm=$(python3 -c "import json; print(json.load(open('.claude/package-manager.json'))['packageManager'])" 2>/dev/null || true)
        if [[ -n "$pm" ]]; then
            echo "$pm"
            return
        fi
    fi

    # 3. package.json packageManager field
    if [[ -f "package.json" ]]; then
        local pm
        pm=$(python3 -c "import json; d=json.load(open('package.json')); print(d.get('packageManager','').split('@')[0])" 2>/dev/null || true)
        if [[ -n "$pm" ]]; then
            echo "$pm"
            return
        fi
    fi

    # 4. Lock file detection
    if [[ -f "bun.lockb" ]] || [[ -f "bun.lock" ]]; then
        echo "bun"
        return
    fi
    if [[ -f "pnpm-lock.yaml" ]]; then
        echo "pnpm"
        return
    fi
    if [[ -f "yarn.lock" ]]; then
        echo "yarn"
        return
    fi
    if [[ -f "package-lock.json" ]]; then
        echo "npm"
        return
    fi

    # 5. pyproject.toml detection (Python)
    if [[ -f "pyproject.toml" ]]; then
        echo "uv"
        return
    fi
    if [[ -f "requirements.txt" ]]; then
        echo "pip"
        return
    fi

    # 6. Go module detection
    if [[ -f "go.mod" ]]; then
        echo "go"
        return
    fi

    # 7. Rust detection
    if [[ -f "Cargo.toml" ]]; then
        echo "cargo"
        return
    fi

    # 8. Global config
    if [[ -f "${HOME}/.claude/package-manager.json" ]]; then
        local pm
        pm=$(python3 -c "import json; print(json.load(open('${HOME}/.claude/package-manager.json'))['packageManager'])" 2>/dev/null || true)
        if [[ -n "$pm" ]]; then
            echo "$pm"
            return
        fi
    fi

    # 9. Fallback: check what's available
    for pm in npm pnpm yarn bun uv pip; do
        if command -v "$pm" &>/dev/null; then
            echo "$pm"
            return
        fi
    done

    echo "unknown"
}

# Print detection result
PM=$(detect_pm)
echo "$PM"
