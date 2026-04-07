# Platform Overview

## Поточний склад платформи

### 1. `api-nodejs`
- Express/Node.js backend
- `POST /api/v1` як legacy RPC шар
- `/ext/*` як інтеграційні та службові endpoint-и
- production-facing частина для:
  - mobile app
  - BAF/1C
  - зовнішніх webhook/integration flows

### 2. `mobile-app-ios`
- legacy iOS app
- використовується для операційних процесів складу/логістики
- напряму залежить від `/api/v1` та частини `/ext/*`

### 3. `BAF / 1C`
- тепер винесений в окремий repo:
  - `baf/`
- dump-каталог конфігурації:
  - `baf/baf-configuration/`
- використовується для:
  - розуміння доменної моделі,
  - встановлення фактичних workflow,
  - звірки endpoint-ів і функцій

## Архітектурна логіка
- BAF/1C є джерелом частини бізнес-логіки та документів.
- `api-nodejs` є інтеграційним шаром між BAF, mobile та зовнішніми сервісами.
- `mobile-app-ios` є операційним клієнтом для складу/логістики.

## Стратегія розвитку
- Зберігати окремі repo.
- Документувати спільні знання на root рівні.
- Не будувати “випадковий monorepo” поверх legacy repo.
- Поступово готувати платформу до:
  - розвитку BAF як окремого repo,
  - можливого Flutter rewrite mobile app,
  - подальшої еволюції backend.
