# Current Workstreams

Цей файл — короткий operational backlog по активних частинах платформи. Він не дублює детальні knowledge-файли, а фіксує поточні напрями роботи.

## 1) `api-nodejs`

### Поточний стан
- Налаштовано кращу observability для nginx:
  - JSON access logs
  - real client IP
  - окремі rich logs для `/api/v1` і `/ext/*`
  - `X-Request-Id` у Node.js
- У Node.js додано:
  - request context через `AsyncLocalStorage`
  - `[req:...]` префікси в логах
  - global error visibility:
    - `NODE-ERROR EXPRESS`
    - `NODE-ERROR UNHANDLED-REJECTION`
    - `NODE-ERROR UNCAUGHT-EXCEPTION`
- Для Monobank wallet flow уже закрито кілька production-проблем:
  - ізоляція помилок імпорту
  - `comment` guard у FOP flow
  - обробка `merchant cancelList`
  - логічний success/error contract для mono wallet endpoint

### Найближчі практичні задачі
- Спостерігати нові `NODE-ERROR *` у production логах і фіксувати патерни.
- Поступово пройти backlog інших `/ext/wallet/*` route-ів з нелогічним response contract.
- У майбутньому оцінити rewrite/replace частини сервісу на Go без втрати legacy contract.

## 2) `mobile-app-ios`

### Поточний стан
- Repo задокументований як legacy iOS baseline.
- Зафіксовано:
  - source of truth = branch `1.0.0`
  - API inventory
  - assessment по rewrite на Flutter/Android
  - production-confirmed mobile workflows

### Найближчі практичні задачі
- Побудувати карту:
  - `screen/controller -> backend functions -> rewrite priority`
- Виділити must-have phase 1 для нового клієнта.
- Окремо описати друк, scanner flow, photo/upload, manifest flow.

## 3) `mobile-app-flutter`

### Поточний стан
- Створено новий каталог `mobile-app-flutter/` як стартову точку для Flutter rewrite.
- Додано:
  - `AGENTS.md`
  - `KNOWLEDGE.md`
  - `docs/project-bootstrap.md`
  - `docs/tooling-and-skills.md`
- Додано реальний Flutter scaffold:
  - `android/`
  - `ios/`
  - `lib/`
  - `pubspec.yaml`
- Реалізовано початковий application layer:
  - auth/bootstrap
  - settings
  - work menu shell
- Реалізовано перший production-relevant feature slice:
  - scanner capture
  - receive order search (`ORDER_BUY_SEARCH`)
  - tracking normalization parity з legacy iOS
  - closer parity for start/settings/work menu and receive list/detail flow
  - `ORDER_LIST`
  - `TRABLES_LIST`
  - `REJECT_ORDER_BUY`
  - local receive validations
- Зібрано перший робочий Android debug APK з локальними `dart-define`.
- Підтверджено, що в host-середовищі відсутні `flutter` і `dart`, але Docker toolchain уже достатній для базової валідації.
- Перевірено curated Codex skills: готового Flutter/Android skill немає.
- Створено локальний custom skill `~/.codex/skills/flutter-android-workflow/`.
- У `mobile-app-flutter/docs/full-migration-rollout-plan.md` зафіксовано повний rollout order:
  - спочатку visual parity за screenshot baseline;
  - потім interaction/backend parity;
  - без нового функціоналу.

### Найближчі практичні задачі
- Дозвірити весь screenshot baseline `01–12` до повного visual parity.
- Додати legacy S3/media upload flow для `SAVE_PHOTO`.
- Замкнути `RESIVE_ORDER_BUY` end-to-end після media parity.
- Перенести unpacking flow.
- Почати Android MVP за execution backlog з `mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`.

## 4) `BAF / 1C`

### Поточний стан
- Створено окремий BAF repo:
  - `baf/`
- Усередині нього є dump-каталог:
  - `baf/baf-configuration/`
- Зафіксовано canonical workflow повторної вигрузки:
  - `baf/docs/export-workflow.md`
- Repo already usable як knowledge source для:
  - розуміння `UA_LIST_ACCOUNT`
  - wallet/import flows
  - звірки endpoint-ів і доменних процесів

### Найближчі практичні задачі
- Перенести частину BAF-specific knowledge з `api-nodejs` у `baf/` та `baf/baf-configuration/`.
- Побудувати більш чітку карту доменної моделі й бізнес-процесів.
- Після наступного dump порівняти його з `baf/baf-configuration` і зрозуміти, чи були реальні зміни.

## 5) Platform-level

### Поточний стан
- Workspace уже має root-level:
  - `AGENTS.md`
  - `KNOWLEDGE.md`
  - platform docs
- Root `logistica/` уже оформлений як parent repo з submodules.
- Це дає змогу починати нові сесії з `logistica/`, а не лише з окремих repo.

### Найближчі практичні задачі
- Коли прийде час переїзду на Forgejo:
  - створити 4 відповідні repo;
  - оновити `origin` у всіх repo;
  - оновити `.gitmodules`;
  - виконати `git submodule sync --recursive`.
