# Full Migration Rollout Plan

## Мета
- Перенести legacy mobile app на `Flutter` так, щоб новий Android-клієнт:
  - виглядав максимально близько до старої апки;
  - проходив ті самі сценарії;
  - не додавав нового функціоналу;
  - не міняв backend contract;
  - не переносив бізнес-правила з `BAF/1C` у клієнт.

## Базове правило міграції
Для кожного сценарію порядок робіт фіксований:

1. **Visual parity**
   - звірити екран зі screenshot;
   - відтворити layout, тексти, кнопки, відступи, кольори, стани.
2. **Interaction parity**
   - відтворити локальну поведінку екрана;
   - відтворити ті ж кнопки, переходи, disabled-стани, alerts.
3. **Backend parity**
   - підключити ті самі RPC/`/ext/*` виклики;
   - не міняти назви функцій, payload shape і семантику відповідей.
4. **Validation**
   - перевірити `flutter analyze`;
   - перевірити `flutter test`;
   - перевірити flow на реальному Android APK.

## Джерела істини
- Legacy UI baseline:
  - `../mobile-app-ios/docs/screenshots/`
- Legacy code:
  - `../mobile-app-ios/`
- Backend contract:
  - `../api-nodejs/`
- Business/domain behavior:
  - `../baf/`

## Жорсткі обмеження
- Не додавати нового функціоналу.
- Не “покращувати” UX до завершення parity.
- Не нормалізувати backend contract без окремого підтвердження.
- Не переносити доменні правила у Flutter.
- Не заміняти screen flow на інший, навіть якщо він виглядає технічно кращим.

## Screenshot-first backlog

### Phase A — Bootstrap / registration / settings / work menu
Ціль: повний візуальний parity для стартового блоку, який бачить користувач до і одразу після логіну.

#### Screenshot set
- `01.jpg`
- `02.png`
- `03.png`
- `04.png`
- `05.png`
- `06.png`
- `07.png`
- `08.png`
- `09.png`
- `10.png`
- `11.png`
- `12.png`

#### Scope
- стартовий екран;
- registration flow;
- settings;
- work menu;
- receive order search/list/detail baseline.

#### Definition of done
- усі тексти кнопок збігаються з legacy;
- структура екранів не відрізняється по сенсу;
- немає placeholder text, яких не було в старій апці;
- disabled/enabled стани кнопок відповідають legacy;
- Android APK дозволяє:
  - зареєструватися;
  - зайти в app;
  - відкрити menu;
  - пошукати замовлення в `Прийняти замовлення`.

### Phase B — Receive order full parity
Ціль: закрити receive flow до operational usable state.

#### Legacy flow
1. Пошук замовлення
2. Список результатів
3. Картка замовлення
4. Перелік товарів
5. Вибір проблеми
6. Фото перевізного / фото прийому
7. `SAVE_PHOTO`
8. `RESIVE_ORDER_BUY`
9. `REJECT_ORDER_BUY`
10. Print path

#### Required parity
- `ORDER_BUY_SEARCH`
- `ORDER_LIST`
- `TRABLES_LIST`
- `SAVE_PHOTO`
- `RESIVE_ORDER_BUY`
- `REJECT_ORDER_BUY`
- той самий порядок локальних перевірок;
- ті самі business-error alerts;
- жодних crash path на error response.

#### Exit criteria
- оператор може пройти flow прийому без ручного fallback на legacy iOS app.

### Phase C — Unpacking parity
Ціль: перенести `Розпакувати` без redesign.

#### Required parity
- search for unpacking;
- item list;
- document type selection;
- фото товару;
- фото документів;
- trable/comment flow;
- `UNPACKING_ORDER_BUY`;
- print after success;
- локальні disabled/processed states на item-level.

### Phase D — Reprint + order details parity
Ціль: закрити допоміжні operator flows.

#### Required parity
- search for reprint;
- `/ext/print/...` path;
- order details read-only mode;
- reuse item/detail UI без зміни логіки.

### Phase E — Manifest parity
Ціль: повністю відтворити сценарій формування маніфесту.

#### Required parity
- `LIST_OPEN_MANIFEST`
- `LIST_MANIFEST_SHIPMENTS`
- `MANIFEST_ADD_DELETE`
- scanner add/delete flow;
- success/error alerts;
- local navigation parity.

### Phase F — Scanner document/cell parity
Ціль: відтворити document scanner workflow.

#### Required parity
- prefix-based scanner interpretation;
- dedup local list;
- `SCANNER_PUSHDOCUMENT`
- `SCANNER_READDOCUMENT_RESULT`
- `SCANNER_READDOCUMENT_<docType>`

### Phase G — Courier / pickup parity
Ціль: перенести ancillary courier workflow без розширення.

#### Required parity
- pickup list;
- pickup detail;
- SMS/phone actions;
- shipment add/scan;
- time/status actions.

### Phase H — Media / background / print hardening
Ціль: закрити platform integrations до production-ready стану.

#### Required parity
- camera flow;
- file naming;
- local staging;
- upload queue;
- retry behavior;
- manual sync;
- print behavior на Android;
- не блокувати майбутній iOS path.

## Execution strategy

### 1. Screen-by-screen discipline
Кожен екран проходить однаковий цикл:
- screenshot audit;
- code audit у legacy iOS;
- Flutter visual parity;
- Flutter behavior parity;
- backend hookup;
- Android test;
- docs update.

### 2. Vertical slices only
Не робити “спочатку всі UI, потім весь backend”.
Правильний порядок:
- завершувати невеликі, але цілісні slices.

Приклад:
- `Прийняти замовлення`:
  - search
  - result list
  - detail
  - photo
  - submit
  - error handling

### 3. No silent redesign
Не вводити:
- нові іконки;
- нові helper texts;
- нові screen states;
- нові CTA;
- нову структуру меню.

Будь-який відступ від legacy — тільки якщо:
- це технічна вимога Android;
- це документовано в `KNOWLEDGE.md`.

## Поточний статус відносно плану

### Already done
- Docker-based Android build environment;
- перший робочий debug APK;
- bootstrap/auth/settings/work menu partial parity;
- receive search/list/detail partial parity;
- scanner capture baseline;
- `ORDER_BUY_SEARCH`, `ORDER_LIST`, `TRABLES_LIST`, `REJECT_ORDER_BUY` підключені.

### Still missing before receive flow is operational
- `SAVE_PHOTO`;
- legacy media upload path;
- `RESIVE_ORDER_BUY` final submit path;
- print parity;
- full visual parity по всіх receive detail states.

## Найближчий порядок робіт

1. Дозвірити `01–12` до повного visual parity.
2. Зафіксувати screenshot-by-screenshot checklist у docs.
3. Закрити `SAVE_PHOTO` + media path.
4. Замкнути `RESIVE_ORDER_BUY`.
5. Перенести `Розпакувати`.
6. Перенести `Передрукувати`.
7. Перенести `Формування маніфесту`.
8. Перенести `Деталі замовлення (PL)`.
9. Лише після цього брати ancillary flows.
