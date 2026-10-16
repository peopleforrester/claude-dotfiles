#!/usr/bin/env python3
# ABOUTME: Unit tests for scripts/validate.py, the Python config validator.
# ABOUTME: Builds fixture trees in a temp dir and checks each validator and the CLI.

import contextlib
import importlib.util
import io
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "scripts" / "validate.py"

spec = importlib.util.spec_from_file_location("validate", SCRIPT)
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)

BODY = "This body explains what the file is for, when to use it, and how. " * 3


def assert_eq(label, actual, expected):
    if actual != expected:
        print(f"FAIL: {label}: expected {expected!r}, got {actual!r}")
        sys.exit(1)
    print(f"  {label}: PASS")


def write(root: Path, rel: str, content: str) -> Path:
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return path


def skill(name="my-skill", description="Does one thing well."):
    lines = ["---"]
    if name is not None:
        lines.append(f"name: {name}")
    if description is not None:
        lines.append(f"description: {description}")
    lines.append("---")
    return "\n".join(lines) + "\n\n# Skill\n\n" + BODY + "\n"


def quiet(fn, *args):
    """Call fn without letting its per-file report reach the test output."""
    with contextlib.redirect_stdout(io.StringIO()):
        return fn(*args)


def run_cli(target: Path) -> int:
    result = subprocess.run(
        [sys.executable, str(SCRIPT), str(target)],
        text=True,
        capture_output=True,
        timeout=30,
    )
    return result.returncode


def test_validate_json(tmp: Path):
    good = write(tmp, "good.json", '{"// NOTE": "comment key", "a": 1}')
    bad = write(tmp, "bad.json", '{"a": 1,}')
    assert_eq("json with // comment key is valid", v.validate_json(good), (True, None))
    ok, err = v.validate_json(bad)
    assert_eq("json trailing comma is invalid", ok, False)
    assert_eq("json error names the syntax problem", err.startswith("JSON syntax error"), True)


def test_frontmatter_parsing():
    content = "---\nname: x\ndescription: |\n  line one\n  line two\n---\nbody\n"
    ok, err, data = v.validate_yaml_frontmatter(content)
    assert_eq("frontmatter parses", (ok, err), (True, None))
    assert_eq("simple key read", data["name"], "x")
    assert_eq("multiline block joined", data["description"], "line one\nline two")

    ok, err, _ = v.validate_yaml_frontmatter("# no frontmatter\n")
    assert_eq("missing frontmatter rejected", ok, False)
    ok, err, _ = v.validate_yaml_frontmatter("---\nname: x\nbody without close\n")
    assert_eq("unclosed frontmatter rejected", err, "Missing closing --- for frontmatter")


def test_validate_skill_md(tmp: Path):
    ok = write(tmp, "ok/SKILL.md", skill())
    assert_eq("valid skill has no errors", v.validate_skill_md(ok), [])

    no_name = write(tmp, "noname/SKILL.md", skill(name=None))
    assert_eq("skill without name", v.validate_skill_md(no_name), ["Missing required field: name"])

    no_desc = write(tmp, "nodesc/SKILL.md", skill(description=None))
    assert_eq("skill without description", v.validate_skill_md(no_desc),
              ["Missing required field: description"])

    upper = write(tmp, "upper/SKILL.md", skill(name="My_Skill"))
    assert_eq("skill name must be lowercase-hyphen", v.validate_skill_md(upper),
              ["name must be lowercase with hyphens: My_Skill"])

    long_name = write(tmp, "long/SKILL.md", skill(name="a" * 65))
    assert_eq("skill name over 64 chars", v.validate_skill_md(long_name),
              ["name exceeds 64 characters: 65"])

    long_desc = write(tmp, "longdesc/SKILL.md", skill(description="d" * 1025))
    assert_eq("skill description over 1024 chars", v.validate_skill_md(long_desc),
              ["description exceeds 1024 characters: 1025"])

    short = write(tmp, "short/SKILL.md", "---\nname: s\ndescription: d\n---\nTiny.\n")
    assert_eq("skill body too short", v.validate_skill_md(short),
              ["SKILL.md body seems too short (< 100 chars)"])


def test_validate_agent_md(tmp: Path):
    ok = write(tmp, "agents/good.md", "---\nname: good\ndescription: Reviews code.\n---\n" + BODY)
    assert_eq("valid agent has no errors", v.validate_agent_md(ok), [])

    bare = write(tmp, "agents/bare.md", "# Agent\n" + BODY)
    assert_eq("agent without frontmatter", v.validate_agent_md(bare),
              ["Agent file should have YAML frontmatter (---)"])

    no_desc = write(tmp, "agents/nodesc.md", "---\nname: nodesc\n---\n" + BODY)
    assert_eq("agent without description", v.validate_agent_md(no_desc),
              ["Missing required field: description"])


def test_validate_rule_md(tmp: Path):
    ok = write(tmp, "rules/good.md", "# Rule\n\n" + BODY * 2)
    assert_eq("valid rule has no errors", v.validate_rule_md(ok), [])

    bad = write(tmp, "rules/bad.md", "no heading, short")
    assert_eq("rule without heading and too short", v.validate_rule_md(bad), [
        "Rule file should have a top-level heading (# Title)",
        "Rule file seems too short (< 200 chars)",
    ])


def test_validate_markdown_links(tmp: Path):
    write(tmp, "docs/target.md", "# Target\n")
    doc = write(tmp, "docs/index.md", "\n".join([
        "[ok](./target.md)",
        "[ok bare](target.md#section)",
        "[ok rooted](/docs/target.md)",
        "[external](https://example.com/missing.md)",
        "[anchor](#heading)",
        "[broken](./missing.md)",
        "```",
        "[in code block](./also-missing.md)",
        "```",
    ]))
    assert_eq("only the broken link is reported", v.validate_markdown_links(doc, tmp),
              ["Broken link: [broken](./missing.md)"])


def test_validate_directory(tmp: Path):
    write(tmp, "settings.json", '{"a": 1}')
    write(tmp, "skills/one/SKILL.md", skill(name="one"))
    write(tmp, "agents/a.md", "---\nname: a\ndescription: An agent.\n---\n" + BODY)
    write(tmp, "rules/r.md", "# Rule\n\n" + BODY * 2)
    write(tmp, "README.md", "[gone](./gone.md)\n")
    checked, errors, warnings = quiet(v.validate_directory, tmp)
    assert_eq("clean tree: files checked", checked, 4)
    assert_eq("clean tree: no errors", errors, 0)
    assert_eq("broken link is a warning, not an error", warnings, 1)

    write(tmp, "broken.json", "{not json}")
    write(tmp, "skills/two/SKILL.md", skill(name=None, description=None))
    _, errors, _ = quiet(v.validate_directory, tmp)
    assert_eq("bad json and bad skill counted as errors", errors, 3)


def test_cli_exit_codes(tmp: Path):
    clean = tmp / "clean"
    write(clean, "ok.json", "{}")
    write(clean, "skills/s/SKILL.md", skill(name="s"))
    assert_eq("cli exits 0 on a clean directory", run_cli(clean), 0)

    dirty = tmp / "dirty"
    write(dirty, "bad.json", "[1, 2,]")
    assert_eq("cli exits 1 when a file fails", run_cli(dirty), 1)

    assert_eq("cli exits 1 on a single bad file", run_cli(dirty / "bad.json"), 1)
    assert_eq("cli exits 1 on a missing path", run_cli(tmp / "nope"), 1)


def fresh(fn):
    with tempfile.TemporaryDirectory() as d:
        fn(Path(d))


if __name__ == "__main__":
    print("tests/test_validate.py")
    fresh(test_validate_json)
    test_frontmatter_parsing()
    fresh(test_validate_skill_md)
    fresh(test_validate_agent_md)
    fresh(test_validate_rule_md)
    fresh(test_validate_markdown_links)
    fresh(test_validate_directory)
    fresh(test_cli_exit_codes)
    print("  all: PASS")
