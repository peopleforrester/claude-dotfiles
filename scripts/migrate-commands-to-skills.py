#!/usr/bin/env python3
# ABOUTME: One-shot migration: commands/<category>/<name>.md -> skills/<category>/<name>/SKILL.md
# ABOUTME: Preserves body, normalizes frontmatter, adds user-invocable: true.

"""Migrate slash commands to user-invocable skills.

Reads every commands/<category>/<name>.md, writes skills/<category>/<name>/SKILL.md
with frontmatter normalized:
  - name: <slug>            (added if missing)
  - description: ...        (carried through if present)
  - user-invocable: true    (added)

The body is copied verbatim. The script refuses to overwrite an existing
target SKILL.md and logs a manifest of every action.

Usage:
    python3 scripts/migrate-commands-to-skills.py --dry-run
    python3 scripts/migrate-commands-to-skills.py --apply
"""
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COMMANDS_DIR = ROOT / "commands"
SKILLS_DIR = ROOT / "skills"

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)


def parse_frontmatter(text: str) -> tuple[dict[str, str], str]:
    """Return (frontmatter dict, body) for a markdown file."""
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}, text
    fm = {}
    body = text[match.end():]
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, _, value = line.partition(":")
        fm[key.strip()] = value.strip()
    return fm, body


def render_frontmatter(fm: dict[str, str]) -> str:
    """Re-emit frontmatter in a stable order."""
    order = ["name", "description", "argument-hint", "model",
             "user-invocable", "allowed-tools"]
    lines = ["---"]
    for key in order:
        if key in fm and fm[key]:
            lines.append(f"{key}: {fm[key]}")
    for key, value in fm.items():
        if key not in order and value:
            lines.append(f"{key}: {value}")
    lines.append("---")
    lines.append("")
    return "\n".join(lines)


def migrate_one(src: Path, apply: bool) -> dict[str, str]:
    rel = src.relative_to(COMMANDS_DIR)
    if rel.name == "README.md":
        return {"src": str(src), "action": "skip-readme"}

    category = rel.parent.as_posix() or "_root"
    slug = rel.stem
    dest_dir = SKILLS_DIR / category / slug
    dest = dest_dir / "SKILL.md"

    if dest.exists():
        return {"src": str(src), "dest": str(dest),
                "action": "skip-collision"}

    text = src.read_text(encoding="utf-8")
    fm, body = parse_frontmatter(text)

    fm.setdefault("name", slug)
    fm["user-invocable"] = "true"

    new_text = render_frontmatter(fm) + body

    if apply:
        dest_dir.mkdir(parents=True, exist_ok=True)
        dest.write_text(new_text, encoding="utf-8")
        src.unlink()

    return {"src": str(src), "dest": str(dest),
            "action": "migrate" if apply else "would-migrate",
            "category": category, "slug": slug}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true",
                        help="Execute the migration (default is dry-run).")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print the migration plan without changes.")
    args = parser.parse_args()
    apply = args.apply and not args.dry_run

    if not COMMANDS_DIR.exists():
        print(f"[skip] {COMMANDS_DIR} does not exist; migration already done.")
        return 0

    sources = sorted(p for p in COMMANDS_DIR.rglob("*.md")
                     if p.name != "README.md")
    print(f"[plan] {len(sources)} command files under {COMMANDS_DIR}")

    manifest = []
    collisions = 0
    for src in sources:
        result = migrate_one(src, apply=apply)
        manifest.append(result)
        if result["action"] == "skip-collision":
            collisions += 1
            print(f"[collision] {result['src']} -> {result['dest']}")
        else:
            print(f"[{result['action']}] {result.get('category')}/{result.get('slug')}"
                  if result.get('slug') else f"[{result['action']}] {result['src']}")

    print()
    print(f"[summary] migrated={sum(1 for m in manifest if m['action'] in ('migrate','would-migrate'))} "
          f"collisions={collisions} skipped-readme={sum(1 for m in manifest if m['action']=='skip-readme')}")

    if apply and collisions == 0:
        # Remove the now-empty commands directory tree.
        for category_dir in sorted(COMMANDS_DIR.iterdir(), reverse=True):
            if category_dir.is_dir():
                # Keep README.md only if no other files remain — otherwise
                # delete the whole tree below us at the end.
                pass
        # Remove residual READMEs and empty dirs.
        readme = COMMANDS_DIR / "README.md"
        if readme.exists():
            readme.unlink()
        for sub in sorted(COMMANDS_DIR.rglob("*"), reverse=True):
            if sub.is_dir():
                try:
                    sub.rmdir()
                except OSError:
                    pass
        try:
            COMMANDS_DIR.rmdir()
            print(f"[cleanup] removed {COMMANDS_DIR}")
        except OSError as e:
            print(f"[warn] could not remove {COMMANDS_DIR}: {e}")

    return 0 if collisions == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
