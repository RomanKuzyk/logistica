# App Architecture

## Ціль
Побудувати новий Flutter-клієнт так, щоб:
- відтворити legacy mobile behavior;
- не переносити доменні правила з BAF/1C у клієнт;
- тримати Android-first implementation без блокування майбутнього iOS support.

## Архітектурний принцип
Додаток ділиться на 3 шари:

1. **Core**
- transport
- config
- logging
- local storage
- navigation
- shared failure handling

2. **Feature modules**
- auth
- settings
- work menu
- receive order
- unpacking
- manifest
- media upload
- scanner
- printing

3. **Shared UI / models**
- базові DTO/model objects
- reusable widgets

## Ownership межі
### Backend-owned
- бізнес-правила
- валідації 1С/BAF
- статуси документів/замовлень
- доступні дії для конкретного сценарію

### Client-owned
- navigation flow
- local registration state
- screen state
- device identity lookup
- media capture orchestration
- upload orchestration
- printer/scanner integration
- local settings

## Auth/bootstrap flow
Legacy behavior:
1. Визначити device identity
2. `MK_SELECT_EMPLOEEY`
3. Якщо користувач уже прив'язаний до девайса:
   - `SELECT_EMPLOEEY`
   - показати кнопку старту роботи
4. Якщо ні:
   - показати flow реєстрації нового користувача
   - `MK_DELETE_EMPLOEEY`
   - `MK_INSERT_EMPLOEEY`
   - `SELECT_EMPLOEEY`

Flutter implementation strategy:
- окремий `AuthRepository`
- окремий `DeviceIdentityService`
- окремий `RegistrationController`
- UI не знає деталей підпису та transport contract

## API layer
### Requirements
- support legacy `/api/v1` RPC contract
- signature = `MD5(API_USER + API_PASSWORD + requestJson + API_SOL)`
- preserve request function names exactly
- preserve parameter payload shape exactly

### API abstraction
- `ApiSigner`
- `ApiClient`
- `ApiRpcRequest`
- `ApiRpcResponse`
- feature-specific repositories above API client

## State management
Для початкового етапу достатній pragmatic feature-oriented state layer:
- `ChangeNotifier` / `ValueNotifier`-friendly controller style
- або lightweight Riverpod-like separation later

Початковий пріоритет:
- простота
- тестованість
- мінімум магії

## Navigation
Початкові маршрути:
- splash/bootstrap
- registration
- settings
- work menu

Далі окремі feature routes додаються по backlog.

## Error handling
- transport errors і business errors розділяти
- user-facing текст не нормалізувати без потреби
- legacy mobile compatibility lessons врахувати:
  - backend error payload shape має бути очікуваним для client parser

## Phase 1 execution priority
1. bootstrap
2. auth/registration
3. settings
4. work menu shell
5. receive order shell

## Поточний статус реалізації
- Уже імплементовано:
  - `AppConfig`
  - `ApiClient`
  - `ApiSigner`
  - `LocalSettingsStore`
  - `DeviceIdentityService`
  - `AuthRepository`
  - `AuthController`
  - `AuthGatePage`
  - `RegistrationPage`
  - `SettingsPage`
  - `WorkMenuPage`
- Ще не імплементовано:
  - camera/scanner integration
  - receive order flow
  - media upload flow
  - manifest flow
  - printer integration
