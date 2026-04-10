# Visible Flow Parity Checklist

## Мета
- Зафіксувати фактичний стан parity для 5 видимих legacy flows з `mobile-app-ios/DNOFFICE/Work.storyboard`.
- Відокремити те, що вже перенесено у Flutter, від того, що ще вимагає Android/device/runtime перевірки.
- Використовувати цей документ як execution baseline для подальшого добивання parity без redesign.

## Scope
У scope цього checklist входять лише 5 активних операторських пунктів головного меню:
- `Прийняти замовлення`
- `Розпакувати`
- `Передрукувати`
- `Формування маніфесту`
- `Деталі замовлення (PL)`

Не входять у цей checklist:
- hidden/commented legacy entry points (`ScanDocuments`, `ProcessIMEI`, pickup ancillary menu gaps);
- print hardening на реальних Android label printers;
- shipment-registration subflows для pickup/USA;
- будь-який новий функціонал поза legacy baseline.

## Джерела істини
### Legacy baseline
- `mobile-app-ios/docs/mobile-screen-flow.md`
- `mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`
- `mobile-app-ios/docs/screenshots/04.png`
- `mobile-app-ios/docs/screenshots/05.png`
- `mobile-app-ios/docs/screenshots/06.png`
- `mobile-app-ios/docs/screenshots/07.png`
- `mobile-app-ios/docs/screenshots/08.png`
- `mobile-app-ios/docs/screenshots/09.png`
- `mobile-app-ios/docs/screenshots/10.png`
- `mobile-app-ios/docs/screenshots/11.png`
- `mobile-app-ios/docs/screenshots/12.png`
- `mobile-app-ios/docs/screenshots/13.png`
- `mobile-app-ios/docs/screenshots/14.png`
- `mobile-app-ios/docs/screenshots/15.png`
- `mobile-app-ios/docs/screenshots/16.png`
- `mobile-app-ios/docs/screenshots/17.png`
- `mobile-app-ios/docs/screenshots/18.png`
- `mobile-app-ios/docs/screenshots/20.png`
- `mobile-app-ios/docs/screenshots/21.png`
- `mobile-app-ios/docs/screenshots/22.png`
- `mobile-app-ios/docs/screenshots/24.png`
- `mobile-app-ios/docs/screenshots/25.png`
- `mobile-app-ios/docs/screenshots/28.png`
- `mobile-app-ios/docs/screenshots/29.png`

### Flutter implementation
- `mobile-app-flutter/lib/features/work_menu/presentation/work_menu_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_result_list_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_detail_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_details_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/reprint_action_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/unpacking_summary_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/unpacking_item_page.dart`
- `mobile-app-flutter/lib/features/manifest/presentation/manifest_list_page.dart`
- `mobile-app-flutter/lib/features/manifest/presentation/manifest_scan_page.dart`

## Зведений статус
| Flow | Contract/code parity | UI parity | Runtime parity | Поточний статус |
| --- | --- | --- | --- | --- |
| `Прийняти замовлення` | high | medium-high | partial | backend-backed, print intentionally unavailable |
| `Розпакувати` | high | medium-high | partial | backend-backed, print intentionally unavailable |
| `Передрукувати` | low-medium | medium | low | search/list є, actual print відкладено |
| `Формування маніфесту` | high | medium-high | partial | backend-backed, потрібна device verification |
| `Деталі замовлення (PL)` | high | medium-high | partial | backend-backed read-only flow |

## 1. Прийняти замовлення
### Legacy baseline
- Screens:
  - `mobile-app-ios/docs/screenshots/06.png`
  - `mobile-app-ios/docs/screenshots/07.png`
  - `mobile-app-ios/docs/screenshots/08.png`
  - `mobile-app-ios/docs/screenshots/09.png`
  - `mobile-app-ios/docs/screenshots/10.png`
  - `mobile-app-ios/docs/screenshots/11.png`
  - `mobile-app-ios/docs/screenshots/12.png`
  - `mobile-app-ios/docs/screenshots/13.png`
- Code:
  - `mobile-app-ios/DNOFFICE/UI/Work/ReciveBigShipments/UIReciveBigShipments.swift`
  - `mobile-app-ios/DNOFFICE/UIShipmentsList.swift`
  - `mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelected.swift`
  - `mobile-app-ios/DNOFFICE/UITrablesTables.swift`

### Flutter mapping
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_result_list_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_detail_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_item_list_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/trable_picker_page.dart`
- `mobile-app-flutter/lib/features/order_search/data/order_search_repository.dart`
- `mobile-app-flutter/lib/features/order_search/data/receive_order_repository.dart`

### Уже перенесено
- search by text + scanner entry;
- auto-open single result / list for multiple results;
- order detail screen з legacy-style actions;
- `Перелік товарів`;
- `Фото перевізного`;
- `Фото прийома`;
- `TRABLES_LIST`;
- `RESIVE_ORDER_BUY`;
- legacy-style validation alerts, включно з вимогою фото перед прийманням;
- seller link і product photo preview без додаткових helper UI.

### Ще не закрито
- actual label printing intentionally disabled; замість legacy AirPrint path показується простий alert `Printing is not available yet.`;
- не підтверджено Android device/runtime behavior на production backend end-to-end;
- не доведено pixel-perfect parity для всіх spacing/fonts/state transitions.

### Висновок
- Це один із двох найсильніше перенесених flows.
- Для MVP бракує не бізнес-логіки, а device verification і printer integration.

## 2. Розпакувати
### Legacy baseline
- Screens:
  - `mobile-app-ios/docs/screenshots/14.png`
  - `mobile-app-ios/docs/screenshots/15.png`
  - `mobile-app-ios/docs/screenshots/16.png`
  - `mobile-app-ios/docs/screenshots/17.png`
  - `mobile-app-ios/docs/screenshots/18.png`
- Code:
  - `mobile-app-ios/DNOFFICE/UI/Work/ReciveBigShipments/UIReciveBigShipments.swift`
  - `mobile-app-ios/DNOFFICE/UIShipmentsList.swift`
  - `mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelectedProcessing.swift`
  - `mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelectListOrder.swift`

### Flutter mapping
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_result_list_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/unpacking_summary_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/unpacking_item_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/unpacking_controller.dart`
- `mobile-app-flutter/lib/features/order_search/data/unpacking_repository.dart`

### Уже перенесено
- unpacking search/list/single-result routing;
- summary card з `Продовжити`;
- item-level processing;
- count editing;
- type-documents selection;
- order photo capture;
- document photo capture;
- trable selection;
- `UNPACKING_ORDER_BUY`;
- legacy validations:
  - `Немає фото товару !`
  - `Оберіть тип  документів (Чек або Умова або Фактура) !`
  - `Немає фото документів !`

### Ще не закрито
- post-submit printing intentionally disabled і замінений на explicit unavailable alert;
- потрібна жива перевірка multi-item сценаріїв на Android;
- не доведено runtime parity для edge cases around repeated submit / partial success states.

### Висновок
- Business path майже весь уже перенесений.
- Головний незакритий технічний борг тут — друк і реальний device run.

## 3. Передрукувати
### Legacy baseline
- Screens:
  - `mobile-app-ios/docs/screenshots/20.png`
  - `mobile-app-ios/docs/screenshots/21.png`
  - `mobile-app-ios/docs/screenshots/22.png`
- Code:
  - `mobile-app-ios/DNOFFICE/UI/Work/ReciveBigShipments/UIReciveBigShipments.swift`

### Flutter mapping
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_result_list_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/reprint_action_page.dart`

### Уже перенесено
- search by text + scanner entry;
- list/single-result routing;
- dedicated reprint action screen з legacy wording/button.

### Ще не закрито
- actual `PRINT_PARCELS_BARCODE` runtime flow зараз не активний у UI;
- legacy print-cancel branch (`User push cancel button...`) не відтворюється, бо actual print поки не запускається;
- потрібне рішення по Android printing before flow можна буде вважати parity-complete.

### Висновок
- Це найменш завершений з 5 видимих flows.
- UI skeleton є, але operational parity напряму залежить від printer integration.

## 4. Формування маніфесту
### Legacy baseline
- Screens:
  - `mobile-app-ios/docs/screenshots/24.png`
  - `mobile-app-ios/docs/screenshots/25.png`
- Code:
  - `mobile-app-ios/DNOFFICE/ProcessingManifest/ListManifest.swift`
  - `mobile-app-ios/DNOFFICE/ProcessingManifest/ListManifestScan.swift`

### Flutter mapping
- `mobile-app-flutter/lib/features/manifest/presentation/manifest_list_page.dart`
- `mobile-app-flutter/lib/features/manifest/presentation/manifest_scan_page.dart`
- `mobile-app-flutter/lib/features/manifest/data/manifest_repository.dart`

### Уже перенесено
- `LIST_OPEN_MANIFEST`;
- manifest list;
- manifest detail;
- barcode scan entry;
- `MANIFEST_ADD_DELETE` add flow;
- `MANIFEST_ADD_DELETE` delete flow;
- legacy-style completion/error alerts.

### Ще не закрито
- потрібна device verification зі справжнім barcode scan і production data;
- swipe-to-delete у Flutter є практичним Android equivalent, але ще не підтверджено як остаточний behavioral match для оператора;
- немає production-confirmed runtime audit по великих маніфестах.

### Висновок
- Flow уже backend-backed і придатний для device тестування.
- Основний ризик тут не в backend contract, а в runtime UX на реальному складі.

## 5. Деталі замовлення (PL)
### Legacy baseline
- Screens:
  - `mobile-app-ios/docs/screenshots/28.png`
  - `mobile-app-ios/docs/screenshots/29.png`
- Code:
  - `mobile-app-ios/DNOFFICE/UI/Work/ReciveBigShipments/UIReciveBigShipments.swift`
  - `mobile-app-ios/DNOFFICE/UIShipmentsList.swift`
  - `mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelectListOrder.swift`

### Flutter mapping
- `mobile-app-flutter/lib/features/order_search/presentation/order_search_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_result_list_page.dart`
- `mobile-app-flutter/lib/features/order_search/presentation/order_details_page.dart`
- `mobile-app-flutter/lib/features/order_search/data/order_search_repository.dart`
- `mobile-app-flutter/lib/features/order_search/data/receive_order_repository.dart`

### Уже перенесено
- `ORDER_ALL_BUY_SEARCH`;
- search/list/single-result routing;
- read-only order detail screen;
- product list and image preview;
- seller site open;
- no-action/read-only semantics without receive/unpack controls.

### Ще не закрито
- потрібна device/runtime перевірка з реальними order images/links;
- можливі дрібні layout divergences проти legacy scene, які ще треба добити screenshot-by-screenshot.

### Висновок
- Це найпростіший з 5 видимих flows.
- Contract parity високий; залишок — це runtime verification і UI polishing.

## Підсумок для execution order
1. Device-run `Прийняти замовлення`.
2. Device-run `Розпакувати`.
3. Device-run `Формування маніфесту`.
4. Device-run `Деталі замовлення (PL)`.
5. Окремо Android print spike для `Передрукувати`, receive print і unpacking print.

## Definition of done для visible-flow parity
- Кожен з 5 menu buttons проходиться на Android без crash path.
- Business errors показуються через modal alerts, а не через silent fail.
- Flutter не додає visible helper/dev UI, якого немає в legacy.
- Media upload і backend RPC contract лишаються legacy-compatible.
- Print або працює operationally, або явно винесений у окремий blocker з узгодженим fallback.
