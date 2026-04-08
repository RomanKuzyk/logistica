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
  - registration page
  - settings page
  - work menu shell
- Реєстрація нового користувача на цьому етапі підтримує manual employee code entry.
- QR scanner capture ще не реалізований і залишається окремим наступним кроком.

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
  - `flutter build apk --debug` — розпочато, підтверджено Android-side dependency setup; повний build лишається окремою наступною валідацією
