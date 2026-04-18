#!/usr/bin/env python3
from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Добавить структурированную запись в журнал памяти проекта."
    )
    parser.add_argument("--request", required=True, help="Пользовательский запрос или milestone.")
    parser.add_argument("--summary", required=True, help="Краткий итог работы.")
    parser.add_argument("--file", action="append", default=[], help="Изменённый файл. Повторять флаг.")
    parser.add_argument("--decision", action="append", default=[], help="Решение или вывод.")
    parser.add_argument("--risk", action="append", default=[], help="Риск, caveat или ограничение.")
    parser.add_argument("--follow-up", action="append", default=[], help="Следующее действие.")
    parser.add_argument(
        "--related-note",
        action="append",
        default=[],
        help="Связанная заметка в формате memory/path/to/note без .md.",
    )
    return parser.parse_args()


def bullet_list(items: list[str], fallback: str) -> str:
    if not items:
        return f"- {fallback}"
    return "\n".join(f"- {item}" for item in items)


def linked_notes(notes: list[str]) -> str:
    base = ["[[memory/index]]", "[[memory/logs/index]]", "[[memory/knowledge/index]]"]
    base.extend(f"[[{note}]]" for note in notes)
    return " | ".join(dict.fromkeys(base))


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    logs_root = repo_root / "memory" / "logs"
    logs_root.mkdir(parents=True, exist_ok=True)

    now = datetime.now().astimezone()
    day_path = logs_root / f"{now.date().isoformat()}.md"
    if not day_path.exists():
        day_path.write_text(
            f"# {now.date().isoformat()}\n\nСвязанные заметки: [[memory/logs/index]] | [[memory/knowledge/index]]\n",
            encoding="utf-8",
        )

    entry = f"""

## Session {now.isoformat(timespec="seconds")}

Связанные заметки: {linked_notes(args.related_note)}

### Запрос

{args.request}

### Итог

{args.summary}

### Изменённые файлы

{bullet_list(args.file, 'Файлы не указаны.')}

### Решения

{bullet_list(args.decision, 'Отдельные решения не зафиксированы.')}

### Риски

{bullet_list(args.risk, 'Явные риски не зафиксированы.')}

### Follow-ups

{bullet_list(args.follow_up, 'Следующие шаги не зафиксированы.')}
"""

    with day_path.open("a", encoding="utf-8") as handle:
        handle.write(entry.rstrip() + "\n")

    print(f"[OK] Запись добавлена в {day_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
