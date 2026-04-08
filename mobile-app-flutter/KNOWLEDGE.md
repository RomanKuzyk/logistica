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
- У поточному середовищі **не встановлені** `flutter` і `dart`.
- Доступні:
  - `java`
  - `adb`
- Відсутні:
  - `gradle`
  - Flutter SDK
- Висновок: поки можна готувати docs, структуру проекту і local skills; scaffold Flutter app потребує встановлення SDK.

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
- Legacy migration docs:
  - `../mobile-app-ios/docs/flutter-android-migration-plan.md`
  - `../mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`

## 8) Журнал змін
### 2026-04-08
- Підготовлено стартовий каркас `mobile-app-flutter/`.
- Зафіксовано, що Flutter SDK у середовищі відсутній, тому робота поки на рівні planning/bootstrap docs.
- Перевірено curated installable skills: готового Flutter/Android skill не знайдено.
- Створено локальний custom skill `flutter-android-workflow` для подальшої роботи з цим rewrite.
