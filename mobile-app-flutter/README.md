# mobile-app-flutter

Новий Flutter-клієнт для логістичної платформи GlobalCars.

## Поточний статус
- Каталог підготовлено як стартову точку для rewrite legacy iOS app на Flutter.
- Поточна ціль першого етапу: **Android-first порт** без змін бізнес-процесів, backend contract і UX-поведінки.
- У проекті вже є:
  - Flutter application scaffold;
  - `android/` і `ios/` platform folders;
  - Docker-based build environment;
  - базовий application layer для auth/bootstrap/settings/work menu shell;
  - scanner capture route;
  - parity-oriented receive order search/list/detail flow для `ORDER_BUY_SEARCH`;
  - `ORDER_LIST`, `TRABLES_LIST`, `REJECT_ORDER_BUY` та local receive validations.
  - перший робочий Android debug APK, зібраний через Docker.
- Flutter SDK на host усе ще не встановлений, але проект уже можна валідувати і збирати через Docker.

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
1. Підключити legacy `SAVE_PHOTO` / S3 media upload flow.
2. Замкнути `RESIVE_ORDER_BUY` end-to-end після photo parity.
3. Перенести unpacking flow.
4. Підключити printer integration.
5. Підтягнути решту work menu flows без redesign.

## Поточний Android artifact
- Debug APK збирається в:
  - `build/app/outputs/flutter-apk/app-debug.apk`
- APK збирається з локальними `dart-define` через:
  - `config/dart_defines.local.json`

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
