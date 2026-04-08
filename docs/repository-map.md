# Repository Map

## Root workspace
- `logistica/`
  - parent git repo
  - platform-level docs і coordination context
  - submodule pointers на `api-nodejs`, `mobile-app-ios`, `baf`

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

### `mobile-app-flutter/`
- Статус: новий Flutter rewrite project hub
- Призначення:
  - Android-first порт legacy mobile app
  - planning/bootstrap docs
  - підготовка нового кросплатформеного клієнта
- Основні knowledge файли:
  - `mobile-app-flutter/AGENTS.md`
  - `mobile-app-flutter/KNOWLEDGE.md`
  - `mobile-app-flutter/docs/*`

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
- Flutter rewrite planning: `mobile-app-flutter/`
- BAF snapshot analysis: `baf/baf-configuration/`

## Git hosting map
- parent:
  - `git@github.com:RomanKuzyk/logistica.git`
- backend:
  - `git@github.com:RomanKuzyk/logistica-nodejs.git`
- mobile:
  - `git@github.com:RomanKuzyk/logistica-mobile-app-ios.git`
- BAF:
  - `git@github.com:RomanKuzyk/logistica-baf.git`
