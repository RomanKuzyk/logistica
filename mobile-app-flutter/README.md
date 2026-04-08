# mobile-app-flutter

Новий Flutter-клієнт для логістичної платформи GlobalCars.

## Поточний статус
- Каталог підготовлено як стартову точку для rewrite legacy iOS app на Flutter.
- Поточна ціль першого етапу: **Android-first порт** без змін бізнес-процесів, backend contract і UX-поведінки.
- У проекті вже є:
  - Flutter application scaffold;
  - `android/` і `ios/` platform folders;
  - Docker-based build environment;
  - базовий application layer для auth/bootstrap/settings/work menu shell.
- Flutter SDK на host усе ще не встановлений, але проект уже можна валідувати через Docker.

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
- `docs/dev-environment.md`
- `docs/app-architecture.md`

## Найближчі кроки
1. Доробити feature-level implementation після auth/bootstrap shell.
2. Додати scanner capture flow.
3. Додати receive order flow (`ORDER_BUY_SEARCH` / `RESIVE_ORDER_BUY`).
4. Підключити media upload і printer integration.

## Конфігурація
- API secrets не закомічені в repo.
- Для реального backend-запуску потрібні `dart-define` значення:
  - `GC_API_URL`
  - `GC_API_USER`
  - `GC_API_PASSWORD`
  - `GC_API_SALT`
- Без них проект лишається валідним як scaffold і UI shell, але network auth flow завершиться конфігураційною помилкою.
- Практичний dev-варіант:
  1. скопіювати `config/dart_defines.example.json`
  2. створити локальний файл `config/dart_defines.local.json`
  3. запускати Flutter з:
     - `--dart-define-from-file=config/dart_defines.local.json`
