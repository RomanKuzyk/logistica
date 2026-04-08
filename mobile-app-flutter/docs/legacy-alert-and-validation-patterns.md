# Legacy Alert and Validation Patterns

## Мета
- Зафіксувати, як стара iOS app реально показує operator-facing повідомлення.
- Використовувати це як джерело істини для Flutter parity.

## Загальний висновок
- Legacy app майже не покладається на transient повідомлення.
- Основний UX-патерн:
  - `SCLAlertView`
  - `UIAlertController`
- Тобто для operator flows правильний parity у Flutter — **modal dialogs**, а не `SnackBar`.

## 1. Registration / settings

### Registration
Файл:
- `../mobile-app-ios/DNOFFICE/RegisterController.swift`

Патерни:
- `Atantion` + `Loading data from ERP error : ...`
- `Atantion` + `Registered error : ...`
- `Atantion` + `Registered error ...`

### Settings
Файл:
- `../mobile-app-ios/DNOFFICE/UISettings.swift`

Патерни:
- `Information` + `Розпочата сінхронізація ..`
- `Atantion` + `Unregistered error : ...`

## 2. Receive order

Файл:
- `../mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelected.swift`

Патерни:
- `Errors` + `Ми нічого не знашйшли ...`
- `Errors` + `Error : ...`
- `REJECT_ORDER_BUY` + `ErrorsDetail`
- `Completed` + `Замовлення повертаємо. Дякую !`
- `ERROR REJECT_ORDER_BUY` + `message`
- `PHOTO` + `Зробіть фото перевізного документу !`
- `SUMMA` + `Обов'язково повинна бути вказана сума...`
- `INCOMING_PARSEL_ORDER_BUY` + `ErrorsDetail`
- `Completed` + `Заявка опрацьована. Дякую !`
- `ERROR REGISTERED` + `message`

## 3. Receive / search

Файли:
- `../mobile-app-ios/DNOFFICE/UI/Work/ReciveBigShipments/UIReciveBigShipments.swift`
- `../mobile-app-ios/DNOFFICE/UIShipmentsList.swift`

Патерни:
- `Помилка !` + `Не заповнено поле для пошуку !`
- `Errors` + `Ми нічого не знашйшли по вказаним ...`
- `Errors` + `Error : ...`

## 4. Unpacking

Файли:
- `../mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelectedProcessing.swift`
- `../mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelectListOrder.swift`

Патерни:
- `Errors` + `Ми нічого не знашйшли за вказаними умовами пошуку!`
- `Errors` + `Error : ...`
- `Помилка` + `Немає фото товару !`
- `Помилка` + `Оберіть тип документів ...`
- `Помилка` + `Немає фото документів !`
- `Completed` + `Замовлення оброблено. Дякую !`
- `Помилка` + `Error : ...`

### Print-related inside unpacking
- `Print` + `Sorry print is not compleated..: ...`
- `Print` + `User push cancel button...`
- `Print` + `Sorry print is not compleated data is null..`

## 5. Manifest

Файли:
- `../mobile-app-ios/DNOFFICE/ProcessingManifest/ListManifest.swift`
- `../mobile-app-ios/DNOFFICE/ProcessingManifest/ListManifestScan.swift`

Патерни:
- `Atantion` + `Loading error : ...`
- `Completed` + `Замовлення видалено з маніфесту . Дякуємо !`
- `Completed` + `Замовлення додано в маніфест . Дякуємо !`
- `Error` + `ErrorsDetail`
- `Error` + `message`

## 6. Reprint

Файли:
- `../mobile-app-ios/DNOFFICE/UI/Work/ReciveBigShipments/UIReciveBigShipments.swift`
- `../mobile-app-ios/DNOFFICE/UIReciveBigShipmentsSelectListOrder.swift`

Патерни:
- `Print` + `User push cancel button...`
- `Print` + `Sorry print is not compleated..: ...`
- `Print` + `Sorry print is not compleated data is null..`

## Flutter parity rule
- Не використовувати `SnackBar` у бізнес-сценаріях оператора.
- Для:
  - validation errors
  - business errors
  - print cancel/error
  - sync info
  - completed messages
  слід використовувати modal dialog semantics, максимально близькі до legacy.
