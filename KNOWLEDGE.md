# KNOWLEDGE.md

Це root-level knowledge hub для workspace `logistica/`. Він описує платформу як систему з кількох частин і звʼязує локальні knowledge-файли окремих repo.

## 1) Активні частини платформи
- `api-nodejs/`
  - production Node.js backend / інтеграційний шар
  - RPC endpoint `POST /api/v1`
  - великий набір `/ext/*` інтеграцій
- `mobile-app-ios/`
  - legacy iOS mobile app
  - source of truth для аналізу: branch `1.0.0`
- `baf/`
  - окремий BAF repo
- `baf/baf-configuration/`
  - каталог зі snapshot-вивантаженням конфігурації BAF/1C
- `print-gateway/`
  - прототип LAN сервісу друку для Brother QL-810W (DK-22223)
  - приймає `pdfUrl` і друкує етикетку в локальній мережі

## 2) Як читати цей workspace
- Root docs = крос-репозиторний контекст.
- Repo docs = локальні технічні деталі.
- Якщо задача стосується кількох частин, починати з root docs, потім переходити в repo-level knowledge.

## 3) Knowledge map
- Платформа:
  - [`docs/platform-overview.md`](docs/platform-overview.md)
  - [`docs/current-workstreams.md`](docs/current-workstreams.md)
  - [`docs/repository-map.md`](docs/repository-map.md)
  - [`docs/workflow-rules.md`](docs/workflow-rules.md)
- BAF:
  - [`baf/README.md`](baf/README.md)
  - [`baf/AGENTS.md`](baf/AGENTS.md)
  - [`baf/KNOWLEDGE.md`](baf/KNOWLEDGE.md)
  - [`baf/docs/export-workflow.md`](baf/docs/export-workflow.md)
- Node.js API:
  - [`api-nodejs/KNOWLEDGE.md`](api-nodejs/KNOWLEDGE.md)
  - [`api-nodejs/docs/knowledge/nodejs-api.md`](api-nodejs/docs/knowledge/nodejs-api.md)
  - [`api-nodejs/docs/knowledge/baf-1c.md`](api-nodejs/docs/knowledge/baf-1c.md)
- Mobile app:
  - [`mobile-app-ios/KNOWLEDGE.md`](mobile-app-ios/KNOWLEDGE.md)
  - [`mobile-app-ios/docs/mobile-app-assessment.md`](mobile-app-ios/docs/mobile-app-assessment.md)
  - [`mobile-app-ios/docs/mobile-api-inventory.md`](mobile-app-ios/docs/mobile-api-inventory.md)
  - [`mobile-app-flutter/KNOWLEDGE.md`](mobile-app-flutter/KNOWLEDGE.md)
- Друк (print-gateway):
  - [`print-gateway/README.md`](print-gateway/README.md)

## 4) Поточна картина системи
- `api-nodejs` — operational центр інтеграцій між mobile/BAF/зовнішніми сервісами.
- `mobile-app-ios` — legacy клієнт складу/логістики, тісно привʼязаний до `/api/v1` та `/ext/*`.
- `baf/` — окремий BAF repo.
- `baf/baf-configuration/` — dump-каталог усередині BAF repo.

## 5) Робочі домовленості
- Не змішувати git-історії проектів.
- Root folder **ініціалізований як parent git repo**.
- `api-nodejs/`, `mobile-app-ios/`, `mobile-app-flutter/` і `baf/` підключені як submodules.
- Якщо BAF частина зростатиме далі, треба:
  - розвивати `baf/` як окремий repo із власними docs/scripts;
  - переносити BAF-specific docs з тимчасових згадок у `api-nodejs` у BAF-level docs;
  - підтримувати актуальні крос-посилання між трьома repo.

## 6) Git topology
- Parent repo:
  - `logistica`
- Submodules:
  - `api-nodejs` → `git@github.com:RomanKuzyk/logistica-nodejs.git`
  - `mobile-app-ios` → `git@github.com:RomanKuzyk/logistica-mobile-app-ios.git`
  - `mobile-app-flutter` → `git@github.com:RomanKuzyk/logistica-mobile-app-flutter.git`
  - `baf` → `git@github.com:RomanKuzyk/logistica-baf.git`
- Практичне правило:
  - спочатку пушити зміни в submodule repo;
  - потім оновлювати gitlink у parent `logistica` і пушити parent repo.
- Для multi-repo задач:
  - спочатку завершити code+docs у всіх зачеплених child repo;
  - потім закомітити і запушити child repo;
  - і лише після цього одним parent commit зафіксувати новий узгоджений стан workspace.

## 7) Клонування і sync
- Повний clone:
  - `git clone --recurse-submodules git@github.com:RomanKuzyk/logistica.git`
- Якщо submodules ще не підтягнуті:
  - `git submodule update --init --recursive`
- Після зміни `.gitmodules` або після зміни remote URLs:
  - `git submodule sync --recursive`

## 8) Forgejo migration note
- Поточна структура свідомо зроблена сумісною з майбутнім переїздом на self-hosted Forgejo.
- Для міграції достатньо змінити remotes у 5 repo і URLs у `.gitmodules`.
- Workspace layout при цьому міняти не треба.

## 9) Правила документування
- Секрети не дублювати.
- Інтеграційні токени/секретні URL описувати лише узагальнено.
- Для прод-інцидентів важливіше зберегти:
  - причину,
  - шлях виявлення,
  - мінімальний фікс,
  - backlog/непокриті зони.
- Docs-only зміни дозволено комітити і пушити без окремого підтвердження.
- Якщо docs належать до тієї ж задачі, що і code change, їх треба включати в той самий repo-level rollout, а не накопичувати як серію дрібних follow-up комітів.

## 10) Журнал змін
### 2026-04-07
- Створено root-level `AGENTS.md` і `KNOWLEDGE.md` для workspace `logistica/`.
- Додано окремі platform-level docs:
  - `docs/platform-overview.md`
  - `docs/repository-map.md`
  - `docs/workflow-rules.md`
- Додано `docs/current-workstreams.md` як короткий operational backlog по:
  - `api-nodejs`
  - `mobile-app-ios`
  - BAF частині
- Зафіксовано поточну структуру платформи:
  - `api-nodejs`
  - `mobile-app-ios`
  - `baf/`
  - `baf/baf-configuration/`
- Узгоджено підхід до knowledge:
  - root docs = крос-репозиторний контекст;
  - repo docs = локальні технічні рішення.

### 2026-04-08
- `logistica/` оформлено як parent git repo.
- `api-nodejs/`, `mobile-app-ios/`, `mobile-app-flutter/` і `baf/` підключено як submodules.

### 2026-04-21
- `api-nodejs`: покращено стабільність імпорту виписок:
  - Monobank: розслаблено match назви банку (визначення по підрядку `універсал` після нормалізації), щоб рахунки не пропускались через різні варіанти назви в 1С.
  - Monobank: додано підтримку формату merchant-токенів у `Password` як `Label:token` через кому (префіксація опису транзакцій для розрізнення мерчантів).
  - Raiffeisen: імпорт зроблено “best-effort” (помилка одного акаунта/транзакції не валить увесь прохід).
- Структуру remotes підготовлено під GitHub repo:
  - `logistica`
  - `logistica-nodejs`
  - `logistica-mobile-app-ios`
  - `logistica-baf`
- Зафіксовано clone/sync workflow для submodules.
- Зафіксовано, що ця схема без structural changes переноситься на Forgejo.
- Додано `mobile-app-flutter/` як новий project hub для Flutter rewrite.
- Зафіксовано, що в середовищі наразі немає `flutter` і `dart`, тому старт виконано з planning/bootstrap docs.
- Перевірено curated Codex skills: готового Flutter/Android skill не знайдено.
- Створено локальний custom skill `~/.codex/skills/flutter-android-workflow/`.

### 2026-04-23
- Друк етикеток (MVP, Brother QL-810W + DK-22223):
  - додано `print-gateway/` (LAN HTTP сервіс), який приймає `pdfUrl` і друкує на Brother через raw 9100;
  - зафіксовано, що на continuous tape принтер додає мінімальні фізичні поля для різу (~3мм + ~3мм), тому фізичні 30мм виходять через ~24мм “контенту”;
  - додано керований `side padding` (quiet zones) як проміжний варіант між `contain` та full-width.
- BAF:
  - задокументовано, як формується PDF для `PRINT_PARCELS_BARCODE` і що саме в макеті `Ярлык` впливає на відступи.
