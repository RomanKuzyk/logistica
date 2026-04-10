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
  - unpacking end-to-end flow:
    - `ORDER_BUY_SEARCH_UNPACKING`
    - `ORDER_LIST`
    - `TRABLES_LIST`
    - `UNPACKING_ORDER_BUY`
    - item photo / documents photo
    - document type validation
    - print-after-success parity
  - reprint print path for `LABEL_ORDER`;
  - read-only order details parity через реальний `ORDER_LIST` flow;
  - scanner documents/cell utility slice:
    - `SCANNER_READDOCUMENT_*`
    - `SCANNER_READDOCUMENT_RESULT`
    - `SCANNER_PUSHDOCUMENT`
    - legacy `-` / `+` / barcode logic;
  - pickup/USA/SMS ancillary slice:
    - `MK_COURIER_USA_LIST_PICKUP`
    - `MK_COURIER_USA_LIST_PICKUP_SHIPMENTS`
    - `LIST_CONTRAGENT_ON_PHONE_USA`
    - `CREATE_PICKUP_ON_ROUTE`
    - `REGISTERED_CONTRAGENT_OPENID`
    - `SMS`
    - `CHANGE_STATUS2`
    - `PICKUPUSA_FINISH_CONTRAGENT`
    - `SET_TIME_STATUS_PICKUP`
    - legacy cancel reasons and pickup time options;
  - SCLAlertView-like legacy alert dialog shell для operator-facing errors/warnings;
  - official Amplify-based S3 media path для Flutter:
    - camera capture
    - PNG normalization
    - direct upload to existing AWS bucket
    - `SAVE_PHOTO`
    - local pending-upload queue + manual sync із settings
  - перший робочий Android debug APK, зібраний через Docker.
  - назва Android app already виставлена як `GlobalCars Logistica`;
  - demo mode за замовчуванням вимкнений.
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
- `docs/full-migration-rollout-plan.md`
- `docs/legacy-alert-and-validation-patterns.md`
- `docs/remaining-parity-blockers.md`

## Найближчі кроки
1. Дозвірити решту screenshot baseline за межами `01–12`.
2. Довести до device-level parity `Деталі замовлення (PL)`, scanner-documents utility і pickup/USA ancillary slice.
3. Довирішити user-facing entry points для hidden/закоментованих legacy utility screens.
4. Доробити shipment-registration subflows у pickup/USA, якщо вони мають входити в Android MVP.
5. Лишити print hardening і receive/reprint print parity на фінальний етап.

## Поточний Android artifact
- Debug APK збирається в:
  - `build/app/outputs/flutter-apk/app-debug.apk`
- Зручний artifact для тестування:
  - `build/gc-logistica.apk`
- APK збирається з локальними `dart-define` через:
  - `config/dart_defines.local.json`

## Build
- З кореня workspace:
  - `make apk`
- Із каталогу проекту:
  - `make apk`
- Обидва варіанти збирають debug APK і копіюють його в:
  - `build/gc-logistica.apk`

## Конфігурація
- API secrets не закомічені в repo.
- Для реального backend-запуску потрібні `dart-define` значення:
  - `GC_API_URL`
  - `GC_API_EXT_URL`
  - `GC_API_USER`
  - `GC_API_PASSWORD`
  - `GC_API_SALT`
  - `GC_AWS_REGION`
  - `GC_AWS_IDENTITY_POOL_ID`
  - `GC_AWS_STORAGE_BUCKET`
- Без них проект лишається валідним як scaffold і UI shell, але network auth flow завершиться конфігураційною помилкою.
- Практичний dev-варіант:
  1. скопіювати `config/dart_defines.example.json`
  2. створити локальний файл `config/dart_defines.local.json`
  3. запускати Flutter з:
     - `--dart-define-from-file=config/dart_defines.local.json`
