# Figma Reference ↔ Native iOS Execution

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/connections/index]] | [[memory/knowledge/concepts/figma-as-design-source]] | [[memory/knowledge/concepts/native-ios-liquid-glass]] | [[memory/knowledge/concepts/simplegym-product-scope]] | [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]] | [[memory/logs/index]]

## Relationship

Дизайн SimpleGym задается в Figma, но реализовываться должен через нативные iOS-паттерны и компоненты. Это означает постоянную трансляцию визуального намерения в системные средства платформы, а не механическое копирование слоев макета.

## Why This Connection Matters

Эта связь будет определять почти каждую UI-задачу в проекте: от выбора компонентов до степени допустимого расхождения между макетом и кодом. Она удерживает баланс между визуальной точностью и качеством нативного опыта.

## Typical Failure Modes

- Слишком буквально воссоздавать Figma-элементы кастомным кодом.
- Игнорировать макет и уходить в произвольную платформенную реализацию без явной причины.
- Не записывать, почему конкретный экран в коде отличается от исходного дизайна.

## Trade-offs

- Более нативная реализация обычно проще в сопровождении, но может требовать визуальных компромиссов.
- Более точное визуальное соответствие Figma может стоить дороже по времени, производительности и доступности.

## Related Concepts

- [[memory/knowledge/concepts/figma-as-design-source]]
- [[memory/knowledge/concepts/native-ios-liquid-glass]]
- [[memory/knowledge/concepts/simplegym-product-scope]]

## Source Logs

- [[memory/logs/index]]
