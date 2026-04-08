# mobile-app-flutter

Новий Flutter-клієнт для логістичної платформи GlobalCars.

## Поточний статус
- Каталог підготовлено як стартову точку для rewrite legacy iOS app на Flutter.
- Поточна ціль першого етапу: **Android-first порт** без змін бізнес-процесів, backend contract і UX-поведінки.
- Flutter SDK у цьому середовищі наразі **не встановлений**, тому каталог поки містить документацію, правила і план старту, а не згенерований Flutter scaffold.

## Вхідні дані для rewrite
- Legacy iOS baseline: `../mobile-app-ios/`
- Backend: `../api-nodejs/`
- BAF/1C: `../baf/`

Ключові дослідницькі матеріали з legacy app:
- `../mobile-app-ios/docs/mobile-app-assessment.md`
- `../mobile-app-ios/docs/mobile-api-inventory.md`
- `../mobile-app-ios/docs/mobile-screen-flow.md`
- `../mobile-app-ios/docs/mobile-business-logic-boundary.md`
- `../mobile-app-ios/docs/flutter-android-migration-plan.md`
- `../mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`

## Документація цього проекту
- `AGENTS.md`
- `KNOWLEDGE.md`
- `docs/project-bootstrap.md`
- `docs/tooling-and-skills.md`

## Найближчі кроки
1. Встановити Flutter SDK і Android toolchain.
2. Згенерувати baseline Flutter-проект.
3. Зафіксувати architecture skeleton.
4. Почати Phase 1 Android MVP за execution backlog з `mobile-app-ios`.
