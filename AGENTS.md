# AGENTS.md

## Роль
Ти працюєш у workspace всієї логістичної платформи GlobalCars. Це не один проект, а кілька повʼязаних частин, які еволюціонують разом:
- `api-nodejs/` — інтеграційний та RPC backend
- `mobile-app-ios/` — legacy iOS клієнт
- `mobile-app-flutter/` — новий Flutter rewrite project hub
- `baf/` — окремий BAF repo
- `baf/baf-configuration/` — каталог зі snapshot-вивантаженням конфігурації BAF/1C

## Базові правила роботи
- Якщо в повідомленні є питання, невизначеність або вибір між підходами: **спочатку відповісти/уточнити, потім діяти**.
- Завжди порядок: **відповідь користувачу → дії**.
- Відповідати тією мовою, якою звертається користувач.
- Якщо зміни торкаються кількох частин платформи, спочатку сформувати короткий план і явно тримати сумісність між ними.

## Як мислити на рівні платформи
- Вважати `api-nodejs`, `mobile-app-ios` і `baf` частинами **однієї системи**, але не змішувати їх git-історії.
- Root-level docs у цьому workspace описують:
  - архітектуру платформи,
  - міжсистемні інтеграції,
  - загальні правила,
  - крос-репозиторні плани.
- Repo-level docs описують локальні деталі конкретного коду.

## Пріоритети
- Пріоритет №1: коректність і backward compatibility інтеграцій.
- Пріоритет №2: мінімальний диф і точкові зміни в legacy-коді.
- Пріоритет №3: явна документація причин, обмежень і побічних ефектів.

## Межі відповідальності
- Не зливати проекти в один repo без окремого підтвердження.
- Не копіювати секрети в нові docs.
- Не робити великі cleanup/refactor без окремого запиту.
- Якщо робота йде з BAF, розрізняти:
  - `baf/` як hub-рівень;
  - `baf/baf-configuration/` як dump-каталог усередині BAF repo.

## Де шукати знання
- Root:
  - [`KNOWLEDGE.md`](KNOWLEDGE.md)
  - [`docs/platform-overview.md`](docs/platform-overview.md)
  - [`docs/current-workstreams.md`](docs/current-workstreams.md)
  - [`docs/workflow-rules.md`](docs/workflow-rules.md)
  - [`docs/repository-map.md`](docs/repository-map.md)
- Repo-level:
  - [`api-nodejs/AGENTS.md`](api-nodejs/AGENTS.md)
  - [`api-nodejs/KNOWLEDGE.md`](api-nodejs/KNOWLEDGE.md)
  - [`mobile-app-ios/AGENTS.md`](mobile-app-ios/AGENTS.md)
  - [`mobile-app-ios/KNOWLEDGE.md`](mobile-app-ios/KNOWLEDGE.md)
  - [`mobile-app-flutter/AGENTS.md`](mobile-app-flutter/AGENTS.md)
  - [`mobile-app-flutter/KNOWLEDGE.md`](mobile-app-flutter/KNOWLEDGE.md)
  - [`baf/AGENTS.md`](baf/AGENTS.md)
  - [`baf/KNOWLEDGE.md`](baf/KNOWLEDGE.md)
  - [`baf/docs/export-workflow.md`](baf/docs/export-workflow.md)

## Документування
- Root `KNOWLEDGE.md` оновлювати, коли:
  - змінюється картина платформи,
  - зʼявляються нові міжсистемні домовленості,
  - зʼявляються нові активні repo/частини.
- Repo-level `KNOWLEDGE.md` оновлювати, коли змінюється конкретний код або локальні технічні рішення.
- Docs-only зміни дозволено комітити і пушити без окремого підтвердження.
- Якщо docs стосуються тієї ж задачі, що і code change, їх треба по можливості включати в той самий repo-level changeset, а не дробити на серію follow-up commits.
- Для multi-repo задач дотримуватися parent/children rollout discipline:
  - спочатку завершити code+docs у всіх зачеплених child repo;
  - потім комітити й пушити child repo;
  - parent `logistica` комітити останнім одним узгодженим pointer update.
