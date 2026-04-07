# Workflow Rules

## Для агентної роботи в цьому workspace

### 1. Починати з контексту
- Якщо задача локальна для одного repo — спочатку читати локальний `AGENTS.md` і `KNOWLEDGE.md`.
- Якщо задача міжрепозиторна — спочатку читати root `AGENTS.md` / `KNOWLEDGE.md`, потім потрібні repo-level docs.

### 2. Межі змін
- Не переносити файли між repo без окремого підтвердження.
- Не робити root-level destructive cleanup.
- У root `logistica/` працювати як у parent repo з submodules, а не як у monorepo.

### 3. Документування
- Крос-проектні правила/контекст — у root docs.
- Локальні технічні рішення — в repo docs.
- Якщо знання важливе для двох частин платформи, допускається короткий дубль у двох knowledge файлах з лінком на первинне джерело.

### 3.1 Git / submodules
- Зміни в коді спочатку комітити і пушити у відповідний submodule repo.
- Лише після цього комітити в parent `logistica` оновлений gitlink.
- Для нового clone:
  - `git clone --recurse-submodules ...`
- Якщо submodules не ініціалізовані:
  - `git submodule update --init --recursive`
- Після зміни `.gitmodules`:
  - `git submodule sync --recursive`

### 4. BAF правила
- `baf/` — це BAF-level hub, не source of truth сам по собі.
- `baf/baf-configuration/` — це dump-каталог усередині BAF repo.
- Не змінювати BAF dump механічно без прямого запиту.

### 5. Rewrite-friendly підхід
- Для legacy-коду пріоритет:
  - зрозуміти фактичний workflow,
  - задокументувати контракт,
  - зробити мінімальний safe-фікс,
  - лише потім планувати більші рефакторинги.
