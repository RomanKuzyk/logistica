# Repository Map

## Root workspace
- `logistica/`
  - platform-level docs і coordination context

## Repo / snapshot map

### `api-nodejs/`
- Статус: активний production backend repo
- Основні knowledge файли:
  - `api-nodejs/AGENTS.md`
  - `api-nodejs/KNOWLEDGE.md`
  - `api-nodejs/docs/knowledge/*`

### `mobile-app-ios/`
- Статус: legacy iOS repo / rewrite baseline
- Основні knowledge файли:
  - `mobile-app-ios/AGENTS.md`
  - `mobile-app-ios/KNOWLEDGE.md`
  - `mobile-app-ios/docs/*`

### `baf/`
- Статус: окремий BAF repo
- Призначення:
  - BAF-specific coordination
  - окремі knowledge/docs ближче до BAF-коду
  - canonical workflow повторної вигрузки dump
- Основні knowledge файли:
  - `baf/AGENTS.md`
  - `baf/KNOWLEDGE.md`
  - `baf/docs/export-workflow.md`

### `baf/baf-configuration/`
- Статус: dump-каталог усередині BAF repo
- Призначення:
  - snapshot конфігурації BAF/1C
  - аналіз metadata/code
  - порівняння між вивантаженнями

### `api-nodejs-orig/`
- Статус: historical/original copy
- Не використовувати як source of truth без окремого підтвердження

## Правило source of truth
- Backend runtime: `api-nodejs/`
- Mobile analysis: `mobile-app-ios/` branch `1.0.0`
- BAF snapshot analysis: `baf/baf-configuration/`
