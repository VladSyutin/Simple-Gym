# Product Scope: SimpleGym

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/concepts/index]] | [[memory/knowledge/concepts/figma-as-design-source]] | [[memory/knowledge/concepts/native-ios-liquid-glass]] | [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]] | [[memory/logs/index]]

## Summary

SimpleGym задуман как iOS-приложение для трекинга силовых тренировок. На текущем этапе устойчиво известно только ядро продукта: приложение должно поддерживать пользовательский сценарий записи и просмотра данных о силовых тренировках.

## Why It Matters

Это понятие задает границы всех следующих продуктовых и технических решений. Именно от него будут зависеть будущие модели данных, структура экранов, сценарии логирования тренировки и приоритеты в MVP.

## Known Patterns

- Продуктовая память должна фиксировать только подтвержденный scope, а не желаемые фичи.
- При уточнении функционала нужно связывать новые сущности с этим note, чтобы не размывать базовое определение продукта.
- Любые новые решения по UX и архитектуре стоит сверять с тем, помогают ли они трекингу силовых тренировок.

## Known Pitfalls

- Преждевременно расширять scope до нерелевантных направлений без подтверждения.
- Путать визуальный референс из Figma с уже утвержденным продуктовым поведением.
- Формулировать знание слишком детально до появления кода, экранов и пользовательских сценариев.

## Related Modules Or Files

- Репозиторий пока не содержит прикладного iOS-кода; при появлении таргета сюда стоит добавить реальные entrypoints и модели домена.
- Figma-макеты будут служить первичным источником для экранов и пользовательских потоков.

## Related Decisions

- [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]]

## Related Concepts

- [[memory/knowledge/concepts/figma-as-design-source]]
- [[memory/knowledge/concepts/native-ios-liquid-glass]]

## Source Logs

- [[memory/logs/index]]
