#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime
from pathlib import Path


def read_title(path: Path) -> str:
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return path.stem.replace("-", " ").replace("_", " ").strip().title()


def display_title(path: Path) -> str:
    if path.parent.name == "logs":
        return path.stem
    return read_title(path)


def note_key(repo_root: Path, path: Path) -> str:
    return path.relative_to(repo_root).with_suffix("").as_posix()


def wikilink(repo_root: Path, path: Path, alias: str | None = None) -> str:
    key = note_key(repo_root, path)
    if alias:
        return f"[[{key}|{alias}]]"
    return f"[[{key}]]"


def collect(directory: Path) -> list[Path]:
    if not directory.exists():
        return []
    result = []
    for path in sorted(directory.glob("*.md")):
        if path.stem == "index" or path.stem.startswith("_") or path.stem == "adr-template":
            continue
        result.append(path)
    return result


def render(repo_root: Path, notes: list[Path], empty_hint: str) -> str:
    if not notes:
        return f"- {empty_hint}"
    return "\n".join(f"- {wikilink(repo_root, note, display_title(note))}" for note in notes)


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def main() -> int:
    repo_root = Path(__file__).resolve().parents[2]
    memory_root = repo_root / "memory"
    knowledge_root = memory_root / "knowledge"
    logs_root = memory_root / "logs"
    concepts_root = knowledge_root / "concepts"
    connections_root = knowledge_root / "connections"
    decisions_root = knowledge_root / "decisions"

    logs = collect(logs_root)
    concepts = collect(concepts_root)
    connections = collect(connections_root)
    decisions = collect(decisions_root)
    generated_at = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")

    write(
        logs_root / "index.md",
        f"""# Журнал сессий

Связанные заметки: [[memory/index]] | [[memory/knowledge/index]] | [[memory/logs/_session-template]]

## Записи
{render(repo_root, sorted(logs, reverse=True), 'Журнал пока пуст.')}

## Последнее обновление
- {generated_at}
""",
    )
    write(
        concepts_root / "index.md",
        f"""# Понятия проекта

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/concepts/_template]]

## Notes
{render(repo_root, concepts, 'Пока пусто.')}

## Последнее обновление
- {generated_at}
""",
    )
    write(
        connections_root / "index.md",
        f"""# Связи между понятиями

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/connections/_template]]

## Notes
{render(repo_root, connections, 'Пока пусто.')}

## Последнее обновление
- {generated_at}
""",
    )
    write(
        decisions_root / "index.md",
        f"""# Архитектурные решения

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/decisions/adr-template]]

## Notes
{render(repo_root, decisions, 'Пока пусто.')}

## Последнее обновление
- {generated_at}
""",
    )
    write(
        knowledge_root / "index.md",
        f"""# Карта знаний

Связанные заметки: [[memory/index]] | [[memory/logs/index]] | [[memory/knowledge/concepts/index]] | [[memory/knowledge/connections/index]] | [[memory/knowledge/decisions/index]]

## Основные разделы
- [[memory/knowledge/concepts/index|Понятия]]
- [[memory/knowledge/connections/index|Связи]]
- [[memory/knowledge/decisions/index|Решения]]

## Быстрый вход
### Понятия
{render(repo_root, concepts, 'Пока пусто.')}

### Связи
{render(repo_root, connections, 'Пока пусто.')}

### Решения
{render(repo_root, decisions, 'Пока пусто.')}

### Последние логи
{render(repo_root, sorted(logs, reverse=True)[:10], 'Пока пусто.')}

## Последнее обновление
- {generated_at}
""",
    )
    write(
        memory_root / "index.md",
        f"""# Память проекта {repo_root.name}

Связанные заметки: [[memory/agents]] | [[memory/logs/index]] | [[memory/knowledge/index]]

## Что здесь хранить
- [[memory/agents|Правила для агента]]
- [[memory/logs/index|Журнал сессий]]
- [[memory/knowledge/index|Карта знаний]]

## Быстрая статистика
- Логов сессий: {len(logs)}
- Понятий: {len(concepts)}
- Связей: {len(connections)}
- Решений: {len(decisions)}

## Последнее обновление
- {generated_at}
""",
    )
    print("[OK] Индексы памяти проекта пересобраны")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
