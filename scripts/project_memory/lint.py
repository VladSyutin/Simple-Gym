#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

WIKILINK_RE = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]")


def existing_notes(repo_root: Path) -> dict[str, Path]:
    notes: dict[str, Path] = {}
    for path in (repo_root / "memory").rglob("*.md"):
        notes[path.relative_to(repo_root).with_suffix("").as_posix()] = path
    return notes


def main() -> int:
    repo_root = Path(__file__).resolve().parents[2]
    memory_root = repo_root / "memory"
    if not memory_root.exists():
        print(f"[ERROR] Не найден каталог {memory_root}")
        return 1

    notes = existing_notes(repo_root)
    basenames: dict[str, list[str]] = {}
    for note_key in notes:
        basenames.setdefault(note_key.split("/")[-1], []).append(note_key)

    issues: list[str] = []
    for path in memory_root.rglob("*.md"):
        for match in WIKILINK_RE.finditer(path.read_text(encoding="utf-8")):
            target = match.group(1).strip().rstrip(".md").lstrip("/")
            if target in notes:
                continue
            if len(basenames.get(target.split("/")[-1], [])) == 1:
                continue
            issues.append(f"{path.relative_to(repo_root)} -> {match.group(0)}")

    if issues:
        print("[ERROR] Найдены битые или неоднозначные ссылки:")
        for issue in issues:
            print(f"- {issue}")
        return 1

    print("[OK] Wikilinks выглядят корректно")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
