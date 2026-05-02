# Concept: Native iOS UI With Liquid Glass

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/concepts/index]] | [[memory/knowledge/concepts/simplegym-product-scope]] | [[memory/knowledge/concepts/figma-as-design-source]] | [[memory/knowledge/connections/figma-reference-to-native-ios-execution]] | [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]] | [[memory/logs/index]]

## Summary

Визуальное направление SimpleGym должно ощущаться как нативное iOS-приложение с опорой на системные паттерны и компоненты, близкие к Liquid Glass, а не как кастомный UI, лишь стилизованный под iPhone.

## Why It Matters

Это влияет на выбор технологического стека, архитектуру экранов, набор компонентов, анимации и ограничения при переносе дизайна из Figma в код. Нативность здесь является не только визуальной целью, но и критерием качества пользовательского опыта.

## Known Patterns

- Предпочитать системные материалы, контейнеры и контролы перед кастомной отрисовкой, если они дают нужный эффект.
- Сначала искать платформенный эквивалент Figma-решению, а уже потом собирать кастомную реализацию.
- Проверять, что визуальный стек не ухудшает читаемость, контраст и скорость взаимодействия.
- Для reminders-like swipe-взаимодействий в списках, где SwiftUI не воспроизводит reveal-state корректно, предпочтительнее UIKit-backed `UITableView`/`UICollectionView` cell с системными swipe actions и отдельным background view, который остаётся на месте, пока content view уезжает.
- Для системного `.segmented` в sheet flows важно сохранять один persistent instance control-а; если segmented пересоздаётся в разных subtree, нативная liquid-glass анимация sliding indicator может пропасть.

## Known Pitfalls

- Делать pixel-perfect копию Figma в ущерб системному поведению iOS.
- Переиспользовать glass-эффекты как декоративный слой без UX-функции.
- Предполагать наличие нужного визуального API без проверки версии iOS и реальных ограничений SwiftUI/UIKit.

## Related Modules Or Files

- Будущие SwiftUI-экраны и экранные контейнеры приложения.
- Будущие файлы с дизайн-токенами, темой и reusable UI-компонентами.

## Related Decisions

- [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]]
- [[memory/knowledge/decisions/adr-0002-ios-26-minimum-deployment-target]]
- [[memory/knowledge/decisions/adr-0003-persistent-native-segmented-control-in-sheets]]

## Related Concepts

- [[memory/knowledge/concepts/simplegym-product-scope]]
- [[memory/knowledge/concepts/figma-as-design-source]]

## Source Logs

- [[memory/logs/index]]
