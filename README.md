# Logistica Workspace

Це root workspace логістичної платформи GlobalCars. Тут зібрані кілька повʼязаних частин системи, які наразі живуть окремо:

- `api-nodejs/` — production Node.js backend / інтеграційний шар
- `mobile-app-ios/` — legacy iOS mobile app
- `baf/` — окремий BAF repo
- `baf/baf-configuration/` — каталог зі snapshot dump конфігурації BAF/1C

## З чого починати

### Для агентної / технічної роботи
- [`AGENTS.md`](AGENTS.md)
- [`KNOWLEDGE.md`](KNOWLEDGE.md)

### Для platform-level контексту
- [`docs/platform-overview.md`](docs/platform-overview.md)
- [`docs/repository-map.md`](docs/repository-map.md)
- [`docs/workflow-rules.md`](docs/workflow-rules.md)
- [`docs/current-workstreams.md`](docs/current-workstreams.md)

## Repo-level knowledge

### Backend
- [`api-nodejs/AGENTS.md`](api-nodejs/AGENTS.md)
- [`api-nodejs/KNOWLEDGE.md`](api-nodejs/KNOWLEDGE.md)

### Mobile app
- [`mobile-app-ios/AGENTS.md`](mobile-app-ios/AGENTS.md)
- [`mobile-app-ios/KNOWLEDGE.md`](mobile-app-ios/KNOWLEDGE.md)

### BAF
- [`baf/README.md`](baf/README.md)
- [`baf/AGENTS.md`](baf/AGENTS.md)
- [`baf/KNOWLEDGE.md`](baf/KNOWLEDGE.md)
- [`baf/docs/export-workflow.md`](baf/docs/export-workflow.md)

## Поточний принцип організації
- Root workspace docs описують платформу як систему.
- Кожен repo зберігає власні локальні rules/knowledge.
- `logistica/` оформлений як **parent git repo**.
- `api-nodejs/`, `mobile-app-ios/` і `baf/` підключені як **git submodules**.

## Як клонити workspace

### Повний клон одразу з submodules
```bash
git clone --recurse-submodules git@github.com:RomanKuzyk/logistica.git
```

### Якщо repo вже склонувався без submodules
```bash
git submodule update --init --recursive
```

### Коли в parent repo змінюються submodule pointers
```bash
git pull
git submodule sync --recursive
git submodule update --init --recursive
```

## Поточні remote repo
- parent workspace:
  - `git@github.com:RomanKuzyk/logistica.git`
- backend:
  - `git@github.com:RomanKuzyk/logistica-nodejs.git`
- mobile app:
  - `git@github.com:RomanKuzyk/logistica-mobile-app-ios.git`
- BAF:
  - `git@github.com:RomanKuzyk/logistica-baf.git`

## Майбутній переїзд на Forgejo
- Поточна структура вже сумісна з переїздом на Forgejo.
- Для міграції достатньо:
  1. створити 4 repo у Forgejo;
  2. оновити `origin` у:
     - `logistica/`
     - `api-nodejs/`
     - `mobile-app-ios/`
     - `baf/`
  3. оновити URLs у `.gitmodules`;
  4. виконати:
     ```bash
     git submodule sync --recursive
     ```
- Тобто міняти layout workspace не потрібно, змінюються лише remotes.
