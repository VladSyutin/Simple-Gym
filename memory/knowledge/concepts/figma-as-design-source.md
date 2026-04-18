# Concept: Figma As The Design Source

Связанные заметки: [[memory/knowledge/index]] | [[memory/knowledge/concepts/index]] | [[memory/knowledge/concepts/simplegym-product-scope]] | [[memory/knowledge/concepts/native-ios-liquid-glass]] | [[memory/knowledge/connections/figma-reference-to-native-ios-execution]] | [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]] | [[memory/logs/index]]

## Summary

Для SimpleGym дизайн уже подготовлен в Figma, поэтому Figma выступает основным источником визуального намерения, композиции экранов и уровня polish, с которым нужно сверять реализацию.

## Why It Matters

Наличие готового дизайна позволяет выстраивать разработку от конкретных экранов и компонентов, а не от абстрактных wireframes. Одновременно это требует дисциплины: перенос должен сохранять замысел дизайна, но учитывать реальные возможности iOS.

## Known Patterns

- Использовать Figma как основной референс для структуры экрана, визуальной иерархии и состояния компонентов.
- Фиксировать в памяти проекта места, где код осознанно отходит от макета ради лучшей нативности или технической устойчивости.
- Перед реализацией новых экранов дополнять память ссылками на соответствующие Figma-сущности или решения, если они становятся частью устойчивого процесса.

## Known Pitfalls

- Считать Figma буквальной спецификацией без учета системных ограничений.
- Терять связь между принятым UI-решением в коде и исходным замыслом макета.
- Не документировать осознанные расхождения между дизайном и реализацией.

## Related Modules Or Files

- Внешние Figma-файлы и фреймы, на основе которых будут собираться экраны приложения.
- Будущие iOS view-слои, соответствующие ключевым Figma-экранам.

## Related Decisions

- [[memory/knowledge/decisions/adr-0001-native-ios-over-custom-recreation]]

## Related Concepts

- [[memory/knowledge/concepts/simplegym-product-scope]]
- [[memory/knowledge/concepts/native-ios-liquid-glass]]

## Source Logs

- [[memory/logs/index]]
