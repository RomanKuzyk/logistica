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
- Root folder поки що не оформлений як окремий git repo.
