#!/usr/bin/env python3
# ABOUTME: Validates JSON, YAML, and SKILL.md files in the repository
# ABOUTME: Checks syntax, frontmatter, and required fields

"""
Configuration Validator for claude-dotfiles

Validates:
- JSON files: syntax and structure
- YAML files: syntax
- SKILL.md files: frontmatter and required fields
- Markdown links: internal references

Usage:
    python scripts/validate.py [path]
    python scripts/validate.py                    # Validate entire repo
    python scripts/validate.py skills/            # Validate specific directory
    python scripts/validate.py skills/tdd/SKILL.md  # Validate specific file
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import List, Tuple, Optional


# Colors for terminal output
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'


def color(text: str, c: str) -> str:
    """Apply color to text if terminal supports it."""
    if sys.stdout.isatty():
        return f"{c}{text}{Colors.END}"
    return text


def success(msg: str) -> None:
    """Print success message."""
    print(f"{color('✓', Colors.GREEN)} {msg}")


def warning(msg: str) -> None:
    """Print warning message."""
    print(f"{color('!', Colors.YELLOW)} {msg}")


def error(msg: str) -> None:
    """Print error message."""
    print(f"{color('✗', Colors.RED)} {msg}")


def info(msg: str) -> None:
    """Print info message."""
    print(f"{color('→', Colors.BLUE)} {msg}")


def validate_json(file_path: Path) -> Tuple[bool, Optional[str]]:
    """Validate JSON file syntax."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Remove comment lines (// pattern used in our JSON files)
        # This is a simple approach - proper JSON doesn't have comments
        lines = content.split('\n')
        cleaned_lines = []
        for line in lines:
            # Skip lines that are just comments
            stripped = line.strip()
            if stripped.startswith('"//'):
                cleaned_lines.append(line)  # Keep comment keys
            else:
                cleaned_lines.append(line)

        cleaned_content = '\n'.join(cleaned_lines)
        json.loads(cleaned_content)
        return True, None
    except json.JSONDecodeError as e:
        return False, f"JSON syntax error: {e}"
    except Exception as e:
        return False, f"Error reading file: {e}"


def validate_yaml_frontmatter(content: str) -> Tuple[bool, Optional[str], dict]:
    """Extract and validate YAML frontmatter from markdown."""
    # Check for frontmatter delimiters
    if not content.startswith('---'):
        return False, "Missing YAML frontmatter (file should start with ---)", {}

    # Find closing delimiter
    end_match = re.search(r'\n---\s*\n', content[3:])
    if not end_match:
        return False, "Missing closing --- for frontmatter", {}

    frontmatter_text = content[3:end_match.start() + 3]

    # Try to parse YAML
    try:
        # Simple YAML parsing without external dependency
        data = {}
        current_key = None
        current_value = []
        in_multiline = False

        for line in frontmatter_text.split('\n'):
            # Skip empty lines
            if not line.strip():
                if in_multiline:
                    current_value.append('')
                continue

            # Check for key: value
            if not line.startswith(' ') and ':' in line:
                # Save previous key if exists
                if current_key and in_multiline:
                    data[current_key] = '\n'.join(current_value).strip()

                key, _, value = line.partition(':')
                key = key.strip()
                value = value.strip()

                if value == '|' or value == '>':
                    in_multiline = True
                    current_key = key
                    current_value = []
                elif value:
                    data[key] = value
                    in_multiline = False
                    current_key = None
                else:
                    data[key] = ''
                    in_multiline = False
            elif in_multiline and current_key:
                current_value.append(line.strip())

        # Save last multiline value
        if current_key and in_multiline:
            data[current_key] = '\n'.join(current_value).strip()

        return True, None, data
    except Exception as e:
        return False, f"YAML parsing error: {e}", {}


def validate_skill_md(file_path: Path) -> List[str]:
    """Validate SKILL.md file."""
    errors = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Cannot read file: {e}"]

    # Validate frontmatter
    valid, err, data = validate_yaml_frontmatter(content)
    if not valid:
        errors.append(err)
        return errors

    # Check required fields
    if 'name' not in data:
        errors.append("Missing required field: name")
    else:
        name = data['name']
        # Validate name format
        if len(name) > 64:
            errors.append(f"name exceeds 64 characters: {len(name)}")
        if not re.match(r'^[a-z][a-z0-9-]*$', name):
            errors.append(f"name must be lowercase with hyphens: {name}")

    if 'description' not in data:
        errors.append("Missing required field: description")
    else:
        desc = data['description']
        if len(desc) > 1024:
            errors.append(f"description exceeds 1024 characters: {len(desc)}")

    # Check for content after frontmatter
    frontmatter_end = content.find('\n---\n', 3)
    if frontmatter_end > 0:
        body = content[frontmatter_end + 5:].strip()
        if len(body) < 100:
            errors.append("SKILL.md body seems too short (< 100 chars)")

    return errors


def validate_markdown_links(file_path: Path, repo_root: Path) -> List[str]:
    """Validate internal markdown links."""
    errors = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        return errors

    # Find markdown links [text](path)
    links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content)

    for text, link in links:
        # Skip external links
        if link.startswith(('http://', 'https://', 'mailto:')):
            continue

        # Skip anchors
        if link.startswith('#'):
            continue

        # Remove anchor from path
        path_part = link.split('#')[0]
        if not path_part:
            continue

        # Resolve relative path
        if path_part.startswith('./'):
            target = file_path.parent / path_part[2:]
        elif path_part.startswith('/'):
            target = repo_root / path_part[1:]
        else:
            target = file_path.parent / path_part

        if not target.exists():
            errors.append(f"Broken link: [{text}]({link})")

    return errors


def find_files(root: Path, pattern: str) -> List[Path]:
    """Find files matching pattern."""
    return list(root.rglob(pattern))


def validate_directory(path: Path) -> Tuple[int, int, int]:
    """Validate all files in directory."""
    errors = 0
    warnings = 0
    files_checked = 0

    repo_root = path

    # Find and validate JSON files
    json_files = find_files(path, '*.json')
    for json_file in json_files:
        # Skip node_modules and other common directories
        if 'node_modules' in str(json_file) or '.git' in str(json_file):
            continue

        files_checked += 1
        valid, err = validate_json(json_file)
        rel_path = json_file.relative_to(path)

        if valid:
            success(f"{rel_path}")
        else:
            error(f"{rel_path}: {err}")
            errors += 1

    # Find and validate SKILL.md files
    skill_files = find_files(path, 'SKILL.md')
    for skill_file in skill_files:
        files_checked += 1
        errs = validate_skill_md(skill_file)
        rel_path = skill_file.relative_to(path)

        if not errs:
            success(f"{rel_path}")
        else:
            for err in errs:
                error(f"{rel_path}: {err}")
            errors += len(errs)

    # Validate markdown links in documentation
    md_files = find_files(path, '*.md')
    for md_file in md_files:
        if 'node_modules' in str(md_file) or '.git' in str(md_file):
            continue

        link_errors = validate_markdown_links(md_file, repo_root)
        rel_path = md_file.relative_to(path)

        for err in link_errors:
            warning(f"{rel_path}: {err}")
            warnings += 1

    return files_checked, errors, warnings


def validate_file(file_path: Path) -> Tuple[int, int]:
    """Validate a single file."""
    errors = 0
    warnings = 0

    if file_path.suffix == '.json':
        valid, err = validate_json(file_path)
        if valid:
            success(str(file_path))
        else:
            error(f"{file_path}: {err}")
            errors += 1

    elif file_path.name == 'SKILL.md':
        errs = validate_skill_md(file_path)
        if not errs:
            success(str(file_path))
        else:
            for err in errs:
                error(f"{file_path}: {err}")
            errors += len(errs)

    elif file_path.suffix == '.md':
        repo_root = file_path.parent
        # Try to find repo root
        current = file_path.parent
        while current != current.parent:
            if (current / '.git').exists() or (current / 'README.md').exists():
                repo_root = current
                break
            current = current.parent

        link_errors = validate_markdown_links(file_path, repo_root)
        if not link_errors:
            success(str(file_path))
        else:
            for err in link_errors:
                warning(f"{file_path}: {err}")
                warnings += 1

    else:
        info(f"Skipping unsupported file type: {file_path}")

    return errors, warnings


def main():
    """Main entry point."""
    print(f"\n{color('claude-dotfiles validator', Colors.BOLD)}\n")

    # Determine what to validate
    if len(sys.argv) > 1:
        target = Path(sys.argv[1])
    else:
        # Default to current directory or script's parent
        target = Path(__file__).parent.parent

    if not target.exists():
        error(f"Path not found: {target}")
        sys.exit(1)

    # Validate
    if target.is_file():
        info(f"Validating file: {target}")
        errors, warnings = validate_file(target)
        files_checked = 1
    else:
        info(f"Validating directory: {target}")
        files_checked, errors, warnings = validate_directory(target)

    # Summary
    print(f"\n{color('Summary', Colors.BOLD)}")
    print(f"  Files checked: {files_checked}")
    print(f"  Errors: {color(str(errors), Colors.RED if errors else Colors.GREEN)}")
    print(f"  Warnings: {color(str(warnings), Colors.YELLOW if warnings else Colors.GREEN)}")

    if errors > 0:
        print(f"\n{color('Validation failed', Colors.RED)}")
        sys.exit(1)
    else:
        print(f"\n{color('Validation passed', Colors.GREEN)}")
        sys.exit(0)


if __name__ == '__main__':
    main()
