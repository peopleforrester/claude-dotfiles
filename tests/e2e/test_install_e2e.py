#!/usr/bin/env python3
# ABOUTME: End-to-end tests: run install.sh into a scratch HOME, then have the
# ABOUTME: real Claude Code CLI (fetched from npm) validate what it installed.

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
INSTALLER = ROOT / "install.sh"

# The Claude Code release the installed config is validated against. Pinned so
# the gate moves only when this line does; see decisions.md (2026-10-17).
CLAUDE_CODE = "@anthropic-ai/claude-code@2.1.302"

PROFILES = sorted(p.stem for p in (ROOT / "settings" / "permissions").glob("*.json"))


def fail(message: str):
    print(f"FAIL: {message}")
    sys.exit(1)


def check(label: str, condition: bool, detail: str = ""):
    if not condition:
        fail(f"{label}{': ' + detail if detail else ''}")
    print(f"  {label}: PASS")


def require_tools():
    """The suite needs bash, npx and the npm registry; say so instead of passing."""
    missing = [tool for tool in ("bash", "node", "npx") if shutil.which(tool) is None]
    if missing:
        fail(
            f"missing {', '.join(missing)}; the E2E suite needs Node 22+ with npx "
            f"and network access to the npm registry to fetch {CLAUDE_CODE}"
        )


def install(home: Path, *args: str, cwd: Path = ROOT) -> subprocess.CompletedProcess:
    """Run the installer with HOME pointed at a scratch directory."""
    env = {**os.environ, "HOME": str(home)}
    result = subprocess.run(
        ["bash", str(INSTALLER), *args],
        cwd=cwd,
        env=env,
        stdin=subprocess.DEVNULL,
        text=True,
        capture_output=True,
        timeout=120,
    )
    if result.returncode != 0:
        fail(f"install.sh {' '.join(args)} exited {result.returncode}\n{result.stdout}{result.stderr}")
    return result


def claude(home: Path, *args: str) -> subprocess.CompletedProcess:
    """Run the pinned Claude Code CLI with HOME pointed at a scratch directory.

    npm keeps its usual cache so the package is downloaded once, not per run.
    """
    env = {
        **os.environ,
        "HOME": str(home),
        "npm_config_cache": os.environ.get("npm_config_cache", str(Path.home() / ".npm")),
        "DISABLE_AUTOUPDATER": "1",
    }
    try:
        return subprocess.run(
            ["npx", "--yes", f"--package={CLAUDE_CODE}", "--", "claude", *args],
            env=env,
            stdin=subprocess.DEVNULL,
            text=True,
            capture_output=True,
            timeout=600,
        )
    except subprocess.TimeoutExpired:
        fail(f"{CLAUDE_CODE} did not finish within 600s; is the npm registry reachable?")


def skill_names() -> set[str]:
    return {p.parent.name for p in (ROOT / "skills").glob("*/*/SKILL.md")}


def test_every_skill_is_where_the_installer_looks():
    # install.sh copies skills/<category>/<skill>/; a SKILL.md at any other
    # depth would be counted in its summary but never installed.
    all_skills = list((ROOT / "skills").rglob("SKILL.md"))
    check(
        "every SKILL.md sits at skills/<category>/<skill>/",
        len(all_skills) == len(list((ROOT / "skills").glob("*/*/SKILL.md"))),
        f"{len(all_skills)} SKILL.md files in total",
    )


def test_install_all(profile: str):
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp)
        install(home, "--all", "--no-backup", "--profile", profile)
        claude_dir = home / ".claude"

        settings = claude_dir / "settings.json"
        source = ROOT / "settings" / "permissions" / f"{profile}.json"
        check(f"[{profile}] settings.json is the profile", settings.read_bytes() == source.read_bytes())
        json.loads((claude_dir / "settings.local.json").read_text())
        check(f"[{profile}] settings.local.json is valid JSON", True)

        installed = {p.parent.name for p in (claude_dir / "skills").glob("*/SKILL.md")}
        check(f"[{profile}] all skills installed", installed == skill_names(),
              f"missing {sorted(skill_names() - installed)}")

        agents = {p.name for p in (ROOT / "agents").glob("*.md")}
        check(f"[{profile}] all agents installed",
              agents == {p.name for p in (claude_dir / "agents").glob("*.md")})

        rules = {p.name for p in (ROOT / "rules" / "common").glob("*.md")}
        installed_rules = {p.name for p in (claude_dir / "rules").glob("*.md")}
        check(f"[{profile}] common rules installed, nothing else", installed_rules == rules,
              f"installed {sorted(installed_rules)}")

        hook = claude_dir / "hooks" / "protect-sensitive-files.py"
        check(f"[{profile}] validator hook is executable", os.access(hook, os.X_OK))

        if sys.platform.startswith("linux"):
            mcp_dir = home / ".config" / "Claude" / "mcp-servers"
        else:
            mcp_dir = home / "Library" / "Application Support" / "Claude" / "mcp-servers"
        servers = {p.name for p in (ROOT / "mcp" / "servers").glob("*.json")}
        check(f"[{profile}] MCP server configs installed",
              servers == {p.name for p in mcp_dir.glob("*.json")})


def test_installed_hook_blocks_sensitive_writes():
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp)
        install(home, "--hooks", "--no-backup")
        hook = home / ".claude" / "hooks" / "protect-sensitive-files.py"
        for path, want in (("/srv/app/.env", 2), ("/srv/app/main.py", 0)):
            result = subprocess.run(
                [str(hook)],
                input=json.dumps({"tool_input": {"file_path": path}}),
                text=True,
                capture_output=True,
                timeout=10,
            )
            check(f"installed hook exits {want} for {path}", result.returncode == want,
                  f"exit {result.returncode}: {result.stderr}")


def test_symlink_install():
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp)
        install(home, "--settings", "--symlink", "--no-backup")
        settings = home / ".claude" / "settings.json"
        check("--symlink links settings.json into the repo",
              settings.is_symlink()
              and settings.resolve() == (ROOT / "settings" / "permissions" / "sandbox-on.json").resolve())


def test_reinstall_backs_up_existing_config():
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp)
        install(home, "--settings")
        (home / ".claude" / "settings.json").write_text('{"mine": true}\n')
        install(home, "--settings")
        backups = list(home.glob(".claude-backup-*"))
        check("reinstall backs up the existing config", len(backups) == 1
              and (backups[0] / "settings.json").read_text() == '{"mine": true}\n',
              f"backups: {backups}")


def test_dry_run_writes_no_files():
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp)
        install(home, "--all", "--dry-run")
        written = [p for p in home.rglob("*") if p.is_file()]
        check("--dry-run --all writes no files", not written, f"wrote {written}")


def test_template_install(template: str):
    with tempfile.TemporaryDirectory() as tmp:
        project = Path(tmp) / "project"
        project.mkdir()
        install(Path(tmp) / "home", "--template", template, cwd=project)
        source = ROOT / "templates" / template
        check(f"[{template}] template CLAUDE.md installed",
              (project / "CLAUDE.md").read_bytes() == (source / "CLAUDE.md").read_bytes())
        if (source / ".claude").is_dir():
            expected = {p.relative_to(source) for p in (source / ".claude").rglob("*")}
            got = {p.relative_to(project) for p in (project / ".claude").rglob("*")}
            check(f"[{template}] template .claude/ installed", expected == got)


def test_claude_code_accepts_installed_config():
    with tempfile.TemporaryDirectory() as tmp:
        home = Path(tmp) / "home"
        install(home, "--all", "--no-backup")
        result = claude(Path(tmp) / "cli-home", "plugin", "validate", "--strict", str(home / ".claude"))
        check(f"{CLAUDE_CODE} plugin validate --strict ~/.claude", result.returncode == 0,
              f"exit {result.returncode}\n{result.stdout}{result.stderr}")


def test_claude_code_rejects_a_broken_skill():
    # Guards the check above against passing vacuously, e.g. if a later CLI
    # stopped finding skills under ~/.claude.
    with tempfile.TemporaryDirectory() as tmp:
        broken = Path(tmp) / "config" / "skills" / "broken"
        broken.mkdir(parents=True)
        (broken / "SKILL.md").write_text("---\nname: broken\nallowed-tools: 5\n---\nbody\n")
        result = claude(Path(tmp) / "cli-home", "plugin", "validate", "--strict", str(broken.parent.parent))
        check(f"{CLAUDE_CODE} rejects a broken skill", result.returncode == 1,
              f"exit {result.returncode}\n{result.stdout}{result.stderr}")


if __name__ == "__main__":
    print("tests/e2e/test_install_e2e.py")
    require_tools()
    test_every_skill_is_where_the_installer_looks()
    for profile in PROFILES:
        test_install_all(profile)
    test_installed_hook_blocks_sensitive_writes()
    test_symlink_install()
    test_reinstall_backs_up_existing_config()
    test_dry_run_writes_no_files()
    for template in ("minimal", "standard", "power-user"):
        test_template_install(template)
    test_claude_code_accepts_installed_config()
    test_claude_code_rejects_a_broken_skill()
    print("  all: PASS")
