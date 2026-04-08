# KNOWLEDGE.md

## 1) Що це за проект
- `mobile-app-flutter/` — новий клієнтський проект для Flutter rewrite логістичної mobile app GlobalCars.
- Поточна стратегія: **Android-first порт** без зміни бізнес-процесів.
- На поточний момент каталог використовується як project hub для плану, правил і підготовки до scaffold.

## 2) Джерела істини
- Legacy behavior baseline:
  - `../mobile-app-ios/`
- Backend/RPC contract:
  - `../api-nodejs/`
- Business/domain behavior:
  - `../baf/`

## 3) Що вже відомо про legacy app
- Основна бізнес-логіка лишається server-owned (`BAF/1C` + `api-nodejs`).
- У mobile app є суттєвий client workflow layer:
  - scanner flow
  - photo/video capture
  - local upload orchestration
  - printing
  - navigation/state machine
  - local settings/session state
- Отже Flutter rewrite — це не тільки UI port, а перенесення client orchestration layer.

## 4) Обмеження rewrite
- Не змінювати backend contract на етапі Android MVP.
- Не змінювати бізнес-процеси без окремого плану.
- Не покладатися на iOS-specific API.
- Зберігати максимально близьку UX/flow-поведінку до legacy app.
- Не додавати новий функціонал, якого не було в legacy app.

## 5) Tooling status
- У поточному host-середовищі **не встановлені** `flutter` і `dart`.
- Доступні:
  - `java`
  - `adb`
- Відсутні:
  - `gradle`
  - Flutter SDK
- Docker доступний і вже використовується як reproducible Flutter toolchain.
- Висновок: локальний host toolchain ще неповний, але проект уже можна розвивати і валідовати через Docker.

## 6) Skills
- Перевірено installable curated skills через `skill-installer`.
- Готових curated skills саме під Flutter/Android не знайдено.
- Для цього workspace створено локальний custom skill:
  - `~/.codex/skills/flutter-android-workflow/`
- Призначення skill:
  - допомога з Flutter project bootstrap;
  - Android-specific інтеграції;
  - перенесення legacy workflow у Flutter feature modules.
- Після створення/оновлення локальних skills Codex варто перезапустити.

## 7) Основні planning docs
- `docs/project-bootstrap.md`
- `docs/tooling-and-skills.md`
- `docs/dev-environment.md`
- `docs/app-architecture.md`
- `docs/full-migration-rollout-plan.md`
- Legacy migration docs:
  - `../mobile-app-ios/docs/flutter-android-migration-plan.md`
  - `../mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`

## 8) Поточний implementation scope
- Створено Flutter project scaffold із platform folders:
  - `android/`
  - `ios/`
- Додано базову project structure:
  - `lib/app`
  - `lib/core`
  - `lib/features`
  - `lib/shared`
- Реалізовано початковий application layer:
  - `AppConfig`
  - `ApiClient`
  - `ApiSigner`
  - `LocalSettingsStore`
  - `DeviceIdentityService`
  - `AuthRepository`
  - `AuthController`
- Реалізовано початкові UI flow:
  - auth/bootstrap gate
  - scanner-based registration from start screen
  - settings page
  - work menu shell з ближчим legacy parity
  - scanner capture page
  - receive order search page
  - receive order results list
  - receive order detail flow
  - unpacking search page
  - unpacking summary shell
  - unpacking item shell
- Перший scanner/search parity already перенесено для receive mode:
  - підтримані scanner formats `qr`, `code128`, `ean13`, `ean8`, `code39`
  - перенесено legacy tracking normalization
  - manual input і scanner input використовують один і той самий пошуковий flow
  - start screen, settings screen, work menu і receive search screen приведені ближче до `01–12` screenshot parity
  - receive result list і receive detail screen також підтягнуті ближче до `07–12` legacy style baseline
  - receive detail тепер має parity-oriented дії для:
    - `ORDER_LIST`
    - `TRABLES_LIST`
    - `REJECT_ORDER_BUY`
    - local receive validations (`фото перевізного`, `сума`, `Без НП`)
  - `Фото перевізного` / `Фото прийома` / `Друк стікера` поки лишаються незавершеними, бо legacy flow залежить від S3 upload + `SAVE_PHOTO`
  - перший Android debug APK уже збирається через Docker
  - для `Розпакувати` уже підключено:
    - `ORDER_BUY_SEARCH_UNPACKING`
    - search/list routing
    - visual shells для `14–18`

## 9) Secret/config strategy
- Legacy iOS app тримає backend secrets у коді, але Flutter rewrite цього не повторює.
- Для Flutter проекту прийнято підхід:
  - секрети не комітяться;
  - tracked only: `config/dart_defines.example.json`;
  - local secrets: `config/dart_defines.local.json`;
  - запуск через `--dart-define-from-file`.
- Для зручності додано helper script:
  - `scripts/flutter-docker`

## 10) Журнал змін
### 2026-04-08
- Підготовлено стартовий каркас `mobile-app-flutter/`.
- Згенеровано Flutter scaffold і додано platform folders `android/` та `ios/`.
- Додано базовий application layer для:
  - auth/bootstrap
  - settings
  - work menu shell
- Реалізовано compatibility-aware legacy `/api/v1` client із MD5 signing contract.
- Зафіксовано, що host Flutter SDK у середовищі відсутній, але Docker toolchain уже робочий.
- Перевірено curated installable skills: готового Flutter/Android skill не знайдено.
- Створено локальний custom skill `flutter-android-workflow` для подальшої роботи з цим rewrite.
- Додано Docker-based dev/build environment.
- Додано practical secret/config workflow через:
  - `config/dart_defines.example.json`
  - `config/dart_defines.local.json` (gitignored)
  - `--dart-define-from-file`
  - `scripts/flutter-docker`
- Валідація через Docker:
  - `flutter pub get` — ok
  - `flutter analyze` — ok
  - `flutter test` — ok
  - `flutter build apk --debug` — ok
- Додано перший реальний feature port поверх bootstrap shell:
  - `features/scanner_capture`
  - `features/order_search`
- Для receive mode вже перенесено:
  - `QRCodeScanner.swift` -> `ScannerCapturePage`
  - `truncateTracking(...)`
  - `ORDER_BUY_SEARCH`
  - branching `0 results / 1 result / many results`
  - `ORDER_LIST`
  - `TRABLES_LIST`
  - `REJECT_ORDER_BUY`
  - local validations перед `RESIVE_ORDER_BUY`
- Підтверджено, що повна parity для receive media flow вимагає legacy-compatible шляху:
  - capture file
  - binary upload у S3/Amplify
  - лише потім `SAVE_PHOTO`
- Отже `RESIVE_ORDER_BUY` end-to-end навмисно не замикається фальшивим local stub без завершення media path.
- Робочий Android artifact зараз збирається у:
  - `build/app/outputs/flutter-apk/app-debug.apk`
- Для локальних збірок використовується:
  - `config/dart_defines.local.json`
  - він не комітиться, але його значення вбудовуються в локально зібраний APK.
- Зафіксовано rollout rule для Flutter rewrite:
  - спочатку screenshot/UI parity;
  - потім interaction parity;
  - потім backend parity;
  - без нового функціоналу і без redesign.
