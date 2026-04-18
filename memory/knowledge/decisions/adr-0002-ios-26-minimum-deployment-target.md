# ADR: iOS 26 As The Minimum Deployment Target

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/decisions/index]] | [[memory/knowledge/concepts/native-ios-liquid-glass]] | [[memory/knowledge/concepts/figma-as-design-source]] | [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]] | [[memory/logs/index]]

## Status

Accepted

## Context

Пользователь явно зафиксировал требование: приложение должно поддерживать все версии iOS, где доступен Liquid Glass. По официальным материалам Apple новый дизайн и Liquid Glass были представлены для `iOS 26` 9 июня 2025 года. Проект находится на раннем этапе и пока не имеет ограничений обратной совместимости, которые заставляли бы поддерживать более ранние версии iOS.

## Decision

- Установить минимальный deployment target приложения на `iOS 26.0`.
- Разрешить прямое использование современных SwiftUI API для Liquid Glass, включая `Glass`, `glassEffect(_:in:)` и связанные паттерны, без слоя обратной совместимости для более старых iOS.
- Не проектировать foundation с учетом downgrade-сценариев для iOS 25 и ниже, пока продуктовые требования не изменятся.

## Alternatives Considered

- Поддерживать более ранние версии iOS и эмулировать Liquid Glass через `Material`, blur и кастомные эффекты: отклонено, потому что это усложняет foundation и противоречит требованию опираться на нативную поддержку Liquid Glass.
- Поднять minimum target выше `iOS 26.0`: отклонено, потому что пользователь просил покрыть все iOS-версии с поддержкой Liquid Glass, а не только последние минорные релизы.

## Consequences

- Foundation можно строить прямо на iOS 26 API без дополнительных fallback-веток.
- Код UI будет проще, а нативность выше.
- Охват устройств с более ранними версиями iOS отсутствует, и это надо будет пересматривать только если изменятся продуктовые требования.

## Related Concepts

- [[memory/knowledge/concepts/native-ios-liquid-glass]]
- [[memory/knowledge/concepts/figma-as-design-source]]

## Source Logs

- [[memory/logs/index]]
