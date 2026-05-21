#!/usr/bin/env python3
"""Generate CLAUDE.md from configured parts."""

import argparse
import importlib.util
import re
import subprocess
import sys
from pathlib import Path


CONFIG_DIR = Path(__file__).resolve().parent


def load_config():
    config_path = CONFIG_DIR / "claude_md_config.py"
    spec = importlib.util.spec_from_file_location("claude_md_config", config_path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Failed to load config from {config_path}")
    config = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(config)
    return config


# Output is written relative to project root (parent of this script's directory)
PROJECT_ROOT = CONFIG_DIR.parent


_ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")


def strip_ansi(text: str) -> str:
    return _ANSI_RE.sub("", text)


def run_command(cmd: str) -> str:
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=PROJECT_ROOT)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed (exit {result.returncode}): {cmd}\n{result.stderr}"
        )
    return strip_ansi(result.stdout.strip())


def read_file(path: str) -> str:
    # Paths in config are relative to the config file's directory
    file_path = CONFIG_DIR / path
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")
    return file_path.read_text().strip()


def generate_part(part: dict) -> str:
    source_type = part["source_type"]
    source = part["source"]

    if source_type == "file":
        content = read_file(source)
    elif source_type == "command":
        content = run_command(source)
    else:
        raise ValueError(f"Unknown source_type: {source_type}")

    # Strip non-breaking spaces (tree and some tools insert \xa0 for alignment)
    content = content.replace("\xa0", " ")

    # Wrap in code block if requested (e.g. for command output like tree)
    if part.get("format") == "code":
        content = f"```\n{content}\n```"

    title = part["title"]
    footer = f"> *Cette section a été générée automatiquement à partir de : `{source}`.*"

    return f"## {title}\n\n{content}\n\n{footer}\n"


def generate_all(config) -> str:
    header = getattr(config, "HEADER", "# CLAUDE.md")
    parts = [header]
    for part in config.PARTS:
        parts.append(generate_part(part))
    return "\n".join(parts)


def cmd_all(config):
    output = generate_all(config)
    output_path = PROJECT_ROOT / config.OUTPUT_PATH
    output_path.write_text(output)
    print(f"Generated {output_path}")

    # Format with mdformat if available (dependency group: claude-md-autoupdate)
    result = subprocess.run(["mdformat", str(output_path)], capture_output=True, text=True)
    if result.returncode == 0:
        print(f"Formatted {output_path} with mdformat")
    else:
        print(f"mdformat not available (install with: uv sync --group claude-md-autoupdate)", file=sys.stderr)


def cmd_part(config, index: int):
    if index < 0 or index >= len(config.PARTS):
        print(f"Error: index {index} out of range (0-{len(config.PARTS) - 1})", file=sys.stderr)
        sys.exit(1)
    print(generate_part(config.PARTS[index]))


def cmd_validate(config):
    errors = []
    for i, part in enumerate(config.PARTS):
        prefix = f"Part {i} ('{part.get('title', '?')}'):"
        if "title" not in part:
            errors.append(f"{prefix} missing 'title'")
        if "source_type" not in part:
            errors.append(f"{prefix} missing 'source_type'")
        elif part["source_type"] not in ("file", "command"):
            errors.append(f"{prefix} invalid 'source_type': {part['source_type']}")
        if "source" not in part:
            errors.append(f"{prefix} missing 'source'")
        elif part.get("source_type") == "file":
            if not (CONFIG_DIR / part["source"]).exists():
                errors.append(f"{prefix} file not found: {CONFIG_DIR / part['source']}")

    if not hasattr(config, "OUTPUT_PATH"):
        errors.append("Missing OUTPUT_PATH")

    if errors:
        print("Validation failed:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    print("Configuration is valid.")


def main():
    parser = argparse.ArgumentParser(description="Generate CLAUDE.md")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("all", help="Generate the full CLAUDE.md")

    part_parser = subparsers.add_parser("part", help="Generate a single part by index")
    part_parser.add_argument("index", type=int, help="Part index")

    subparsers.add_parser("validate", help="Validate the configuration")

    args = parser.parse_args()
    config = load_config()

    if args.command == "all":
        cmd_all(config)
    elif args.command == "part":
        cmd_part(config, args.index)
    elif args.command == "validate":
        cmd_validate(config)


if __name__ == "__main__":
    main()