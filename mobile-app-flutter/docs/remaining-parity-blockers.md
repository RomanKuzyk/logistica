# Remaining Parity Blockers

## Стан на 2026-04-10
Після останнього screenshot/code audit видимий legacy work menu (`mobile-app-ios/DNOFFICE/Work.storyboard`) має 5 активних операторських пунктів:
- `Прийняти замовлення`
- `Розпакувати`
- `Передрукувати`
- `Формування маніфесту`
- `Деталі замовлення (PL)`

Ці 5 напрямів у Flutter уже мають backend-backed implementation slice. Залишкові роботи нижче або потребують реального device/backend verification, або не мають підтвердженого активного entry point у legacy UI.

## Блокери перед operational parity

### 1. Print hardening
- Стосується receive/reprint/unpacking print paths.
- Flutter уже має `LegacyPrintService` і серверні `/ext/print/...` fetch paths.
- Не закрито:
  - реальна Android-друкарська поведінка;
  - Brother/Codex label-printer compatibility;
  - fallback strategy, якщо Android system print не дає потрібного label output.

### 2. Device-level verification
- Потрібна перевірка на реальному Android APK проти production backend:
  - login/registration;
  - receive `RESIVE_ORDER_BUY`;
  - unpacking `UNPACKING_ORDER_BUY`;
  - manifest add/delete;
  - details read-only;
  - reprint request path.
- Без цього код можна вважати перенесеним по contract/code parity, але не production-confirmed.

### 3. Scanner-documents utility entry point
- Legacy code є в `UIProcessingScanner/UIProcessScanner.swift`.
- У `UIWorkController.swift` entry point `ScanDocuments` закоментований.
- Flutter має utility slice:
  - `SCANNER_READDOCUMENT_*`
  - `SCANNER_READDOCUMENT_RESULT`
  - `SCANNER_PUSHDOCUMENT`
- Не підключено в меню, бо без підтвердження активного legacy entry point це створило б новий видимий функціонал.

### 4. Pickup/USA ancillary entry point
- Legacy code є в `UICourierUSA*`, `SMS*`, `CancelPickup`, `ProcessingPickupAddScanShipments`.
- Видимого пункту в `Work.storyboard` для цього flow не знайдено.
- Flutter має частковий ancillary slice:
  - pickup list/detail;
  - call/SMS/cancel/time/finish confirmation;
  - create pickup by phone/contragent lookup.
- Не підключено в меню, бо active production entry point не підтверджений screenshot-backed flow.

### 5. Pickup shipment-registration subflows
- Ще не перенесено:
  - `RegisterShipmentsList`
  - `RegisterShipments`
  - `RegisterShipmentsFromClient`
  - `RegisterShipmenstScanner`
  - `RegisterShipmentsDetailPrice`
  - `CREATE_ORDER_PARCEL_NEW`
  - `CREATE_ORDER_PARCEL_NEW_AGENTS`
- Це P1 ancillary scope, а не частина 5 видимих складських menu buttons.

### 6. Task/IMAI media flow
- Legacy `ProcessIMEI` у `UIWorkController.swift` закоментований.
- У `Base.lproj/RegisterController.storyboard` є orphan/old `Process for IMEI` scene, але він не виглядає активним route у поточному visible work menu.
- Не переносити без нового підтвердження, бо це може створити новий visible flow, якого оператор зараз не бачить.

## Практичний порядок далі
1. Прогнати актуальний `gc-logistica.apk` на Android девайсі через 5 видимих menu flows.
2. Винести print на окремий Android printer spike.
3. Після підтвердження активності hidden flows вирішити, чи підключати scanner-documents і pickup/USA в меню.
4. Якщо pickup/USA входить у MVP — окремо переносити shipment-registration subflows.
