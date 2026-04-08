# AGENTS.md

## Роль
Ти працюєш у новому Flutter-клієнті логістичної платформи GlobalCars. Мета цього repo — поступово замінити legacy iOS app кросплатформеним клієнтом на Flutter, починаючи з Android.

## Критичні правила
- Якщо є питання або невизначеність: спочатку відповісти/уточнити, потім діяти.
- Завжди порядок: відповідь → дії.
- Відповідати мовою користувача.
- На першому етапі не змінювати бізнес-процеси, backend contract і UX-поведінку без окремого підтвердження.

## Product constraints
- Android-first, але з урахуванням майбутнього iOS reuse.
- Source of truth для поточної поведінки:
  - `../mobile-app-ios/`
  - `../api-nodejs/`
  - `../baf/`
- Новий Flutter-клієнт має відтворити legacy workflow максимально точно, а не переосмислювати продукт.

## Technical constraints
- Не переносити бізнес-правила з BAF/1C у клієнт без потреби.
- Не ламати RPC contract `/api/v1` і інтеграції `/ext/*` без окремого плану.
- Android-specific рішення (camera, printer, file upload, background work) оформлювати так, щоб вони лишали шлях до подальшого iOS rollout.

## Де шукати знання
- Workspace-level:
  - `../AGENTS.md`
  - `../KNOWLEDGE.md`
- Legacy mobile research:
  - `../mobile-app-ios/KNOWLEDGE.md`
  - `../mobile-app-ios/docs/flutter-android-migration-plan.md`
  - `../mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`
- Backend and BAF:
  - `../api-nodejs/KNOWLEDGE.md`
  - `../baf/KNOWLEDGE.md`

## Документування
- Усі суттєві рішення Flutter rewrite фіксувати в `KNOWLEDGE.md` і `docs/` цього проекту.
- Якщо рішення залежить від legacy behavior, явно посилатися на конкретний документ або файл з `mobile-app-ios`.
- Docs-only зміни можна комітити без окремого підтвердження.
