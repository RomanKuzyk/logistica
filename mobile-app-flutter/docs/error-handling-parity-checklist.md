# Error Handling Parity Checklist

## Мета
- Зафіксувати, як уже перенесені Flutter flows поводяться на validation/business/transport/parsing помилках.
- Окремо відзначити, де Flutter уже відповідає legacy alert pattern, а де ще є розриви.

## Scope
У цьому checklist враховані лише вже перенесені та видимі для оператора flows:
- auth / registration / start
- search/list routing
- `Прийняти замовлення`
- `Розпакувати`
- `Формування маніфесту`
- `Деталі замовлення (PL)`

Printing тут оцінюється лише з точки зору user-facing fallback:
- зараз замість runtime print flow показується explicit alert `Printing is not available yet.`

## Backend error contract
### Поточна поведінка Flutter
- `ApiClient` обробляє backend envelope з `successful=false`.
- Якщо backend повертає `errorsstack`:
  - як `String` — message береться напряму;
  - як `Map` — message береться з `errorsstack.message`.
- Це реалізовано в:
  - `mobile-app-flutter/lib/core/api/api_client.dart`

### Висновок
- Flutter не залежить жорстко від одного формату `errorsstack`.
- Для кейсу, подібного до `Проведіть звірку каси!`, якщо backend поверне business error через `errorsstack`, користувач повинен отримати alert, а не crash.

## Flow-by-flow status

### 1. Auth / registration / start
**Validation / local state**
- registration-required і ready-to-start стани показуються без crash path.

**Backend / transport / parsing errors**
- `AuthController` переводить flow у `AuthStatus.error` з `errorMessage`.
- `AuthGatePage` один раз показує modal alert через `showLegacyAlertDialog(...)`.

**Статус**
- `alert parity`: good
- `no-crash expectation`: good

### 2. Search / list routing
**Validation**
- порожній search input → alert `Error : Не заповнено поле для пошуку.`

**Business / transport / parsing**
- `OrderSearchController` ловить `ApiBusinessException`, `ApiException`, unexpected errors;
- `OrderSearchPage` показує modal alert для `error`;
- порожній результат теж показується через alert, а не silent state.

**Статус**
- `alert parity`: good
- `no-crash expectation`: good

### 3. Receive (`Прийняти замовлення`)
**Validation**
- немає фото перевізного → alert
- нульова сума без disable flag → alert

**Business errors**
- `RESIVE_ORDER_BUY` мапиться через legacy fields:
  - `Error`
  - `ErrorsDetail`
- якщо `Error != 0`, UI показує `result.errorDetail` у modal alert.

**Transport / parsing**
- `ApiException` теж показується в modal alert.

**Статус**
- `alert parity`: good
- `no-crash expectation`: good
- `кейс незакритої каси`: очікується alert, якщо backend поверне business error text

### 4. Unpacking (`Розпакувати`)
**Validation**
- немає фото товару → alert
- не вибрано тип документів → alert
- немає фото документів → alert

**Business errors**
- `UNPACKING_ORDER_BUY` мапиться через legacy `Error` / `ErrorsDetail`
- якщо `Error != 0`, UI показує modal alert з `Error : ...`

**Transport / parsing**
- `ApiException` на submit показується через alert.

**Поточний parity gap**
- load error на етапі завантаження item list зараз відображається inline text state, а не modal alert:
  - `mobile-app-flutter/lib/features/order_search/presentation/unpacking_item_page.dart`
- це не crash path, але це не повна legacy alert parity.

**Статус**
- `submit error handling`: good
- `load error alert parity`: partial

### 5. Manifest (`Формування маніфесту`)
**Business errors**
- `LIST_OPEN_MANIFEST`, `LIST_MANIFEST_SHIPMENTS`, `MANIFEST_ADD_DELETE`
- add/delete business errors показуються через alert з `errorDetail`

**Transport / parsing**
- loading/add/delete exceptions теж ідуть у modal alerts.

**Статус**
- `alert parity`: good
- `no-crash expectation`: good

### 6. Details (`Деталі замовлення (PL)`)
**Business / transport / parsing**
- `ORDER_LIST` load errors показуються через modal alert.
- empty result теж показується через modal alert.

**Статус**
- `alert parity`: good
- `no-crash expectation`: good

## Residual gaps
### Confirmed
- `unpacking` load error uses inline text instead of modal alert.

### Still needs device verification
- camera permission denied / capture failure on real Android devices;
- S3 upload failures during `SAVE_PHOTO` path on real devices;
- manifest scanner runtime failures on real hardware;
- Android back-stack behavior after repeated error dialogs.

## Practical conclusion
- Для вже перенесених visible flows Flutter зараз значно ближчий до legacy iOS по error handling, ніж legacy crash-prone paths.
- Найважливіше:
  - business errors не мають губитися мовчки;
  - вони переважно доходять до modal alert;
  - кейс на кшталт `Проведіть звірку каси!` не виглядає як crash-risk path у поточній Flutter реалізації.
- Головний явний незакритий parity gap у цьому зрізі:
  - `unpacking` load error state.
