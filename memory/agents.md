# Правила работы с памятью проекта

Связанные заметки: [[memory/index]] | [[memory/logs/index]] | [[memory/knowledge/index]]

## Как читать память

1. Сначала открыть [[memory/index]].
2. Затем открыть [[memory/knowledge/index]].
3. Затем прочитать релевантные notes из:
   - [[memory/knowledge/concepts/index]]
   - [[memory/knowledge/connections/index]]
   - [[memory/knowledge/decisions/index]]
4. Если уверенности мало, открыть [[memory/logs/index]] и свежие дневные записи.
5. После этого читать код, тесты и git history.

## Как использовать память

- Считать knowledge-слой рабочей гипотезой, а не абсолютной истиной.
- Проверять код перед изменениями, если заметки выглядят устаревшими.
- Фиксировать новые решения и риски после законченного milestone.
- Поддерживать явные wiki-ссылки между связанными notes.

## Как обновлять память

- Для журналов использовать `scripts/project_memory/log_session.py`.
- Для пересборки индексов использовать `scripts/project_memory/flush.py`.
- Для проверки целостности использовать `scripts/project_memory/lint.py`.

## Текущий контекст проекта

- [[memory/knowledge/concepts/simplegym-product-scope|SimpleGym]] развивается как iOS-приложение для трекинга силовых тренировок.
- Дизайн подготавливается в Figma и служит основным визуальным референсом: [[memory/knowledge/concepts/figma-as-design-source]].
- Приоритет интерфейса: нативность iOS и использование системного языка, близкого к [[memory/knowledge/concepts/native-ios-liquid-glass|Liquid Glass]].
- В репозитории уже создан базовый iOS scaffold: `project.yml`, `SimpleGym.xcodeproj`, app shell и стартовый `DesignSystem`.
- Минимальный deployment target зафиксирован на `iOS 26.0`: [[memory/knowledge/decisions/adr-0002-ios-26-minimum-deployment-target]].

## На что смотреть в начале сессии

1. Проверить [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]].
2. Проверить [[memory/knowledge/decisions/adr-0002-ios-26-minimum-deployment-target]].
3. Прочитать релевантные concepts по продукту, Figma и нативному UI.
4. Если начинается реализация экранов, перепроверить доступность нужных iOS API и только потом переносить решения из Figma в код.
