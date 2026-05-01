# ADR: Keep Sheet Segmented Controls Persistent For Native Liquid Glass Animation

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/decisions/index]] | [[memory/knowledge/concepts/native-ios-liquid-glass]] | [[memory/knowledge/concepts/figma-as-design-source]] | [[memory/logs/index]]

## Status

Accepted

## Context

В flow добавления тренировки SimpleGym использует системный `Picker` со стилем `.segmented` как часть sheet-интерфейса. При переносе Figma-driven экрана на SwiftUI оказалось, что визуально одинаковый segmented control теряет нативное "скользящее стекло", если его инстанс пересоздаётся при переключении между разными ветками layout. В таком состоянии пользователь видит смену selected state, но не получает системную анимацию liquid-glass indicator.

## Decision

- В sheet-сценариях, где segmented control должен сохранять нативную системную анимацию, держать его одним и тем же persistent view.
- Менять только контент под segmented control, а не пересоздавать сам control в разных `switch`/`if`-ветках.
- Если под одним из состояний segmented control визуально не нужен внутри дочернего view, резервировать под него место layout’ом, а не переносить control в другой subtree.

## Alternatives Considered

- Хранить отдельный `Picker(.segmented)` внутри каждого состояния листа: отклонено, потому что это ломает continuity системной анимации и делает переключение визуально менее нативным.
- Пытаться имитировать native sliding indicator кастомной анимацией: отклонено, потому что это добавляет лишнюю UI-логику и противоречит принципу native iOS first.

## Consequences

- Для sheet flows придётся чуть внимательнее проектировать hierarchy верхнего chrome, чтобы segmented control оставался постоянным.
- Нативная liquid-glass анимация и поведение `UISegmentedControl` сохраняются без кастомной имитации.
- При дальнейших Figma-driven доработках segmented-переключателей стоит сначала проверять continuity view identity, а не только визуальное совпадение layout.

## Related Concepts

- [[memory/knowledge/concepts/native-ios-liquid-glass]]
- [[memory/knowledge/concepts/figma-as-design-source]]

## Source Logs

- [[memory/logs/index]]
