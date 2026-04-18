# ADR: Native iOS First, Figma-Driven But Not Figma-Locked

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/decisions/index]] | [[memory/knowledge/concepts/simplegym-product-scope]] | [[memory/knowledge/concepts/figma-as-design-source]] | [[memory/knowledge/concepts/native-ios-liquid-glass]] | [[memory/knowledge/connections/figma-reference-to-native-ios-execution]] | [[memory/logs/index]]

## Status

Accepted

## Context

SimpleGym планируется как iOS-приложение для трекинга силовых тренировок. Пользователь заранее подготовил дизайн в Figma и отдельно обозначил приоритет на нативность интерфейса и использование компонентов в духе Liquid Glass. Репозиторий пока находится на стадии bootstrap и еще не содержит прикладной код, поэтому стартовое решение должно задать рамку для всех будущих UI-реализаций.

## Decision

- Использовать Figma как основной источник визуального намерения и композиции экранов.
- При реализации интерфейсов отдавать приоритет нативным iOS-паттернам, системным материалам и компонентам перед кастомной recreation-логикой.
- Если конкретный Figma-элемент конфликтует с системным поведением, доступностью, производительностью или API-ограничениями iOS, выбирать нативную адаптацию и фиксировать это как осознанное отклонение.

## Alternatives Considered

- Полностью воспроизводить все Figma-слои кастомным UI-кодом: отклонено из-за риска хрупкости, перерасхода времени и ухудшения нативности.
- Использовать Figma только как moodboard без обязательной связи с реализацией: отклонено, потому что проект изначально опирается на подготовленный дизайн.

## Consequences

- Реализация экранов будет быстрее и устойчивее, если нужный эффект покрывается системными средствами iOS.
- Некоторые визуальные решения из макетов могут потребовать адаптации, а не буквального переноса.
- В памяти проекта нужно будет отдельно фиксировать заметные расхождения между Figma и кодом.

## Related Concepts

- [[memory/knowledge/concepts/simplegym-product-scope]]
- [[memory/knowledge/concepts/figma-as-design-source]]
- [[memory/knowledge/concepts/native-ios-liquid-glass]]

## Source Logs

- [[memory/logs/index]]
