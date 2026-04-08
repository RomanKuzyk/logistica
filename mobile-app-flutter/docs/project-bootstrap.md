# Project Bootstrap

## Мета
Підготувати новий Flutter-клієнт як Android-first порт legacy iOS app без зміни бізнес-поведінки.

## Мінімальний bootstrap scope
1. Встановити Flutter SDK.
2. Переконатися, що доступні Android SDK / emulator / adb.
3. Згенерувати Flutter application scaffold.
4. Зафіксувати базову структуру feature modules.
5. Винести platform integrations у контрольовані adapter-і.

## Рекомендований стартовий стек
- Flutter stable
- Dart stable
- Android SDK
- JDK 17 або сумісна версія, рекомендована актуальним Flutter stable
- `melos` — тільки якщо проект стане monorepo або package-split

## Початкова структура проекту
Рекомендовано після scaffold привести проект до такого вигляду:

```text
lib/
  app/
  core/
    api/
    config/
    logging/
    navigation/
    storage/
  features/
    auth/
    work_menu/
    receive_order/
    unpacking/
    manifest/
    media_upload/
    scanner/
    printing/
    settings/
  shared/
    models/
    widgets/
```

## Phase 1 Android MVP
P0 потоки:
- bootstrap / settings
- login/registration equivalents
- work menu
- order receive
- photo capture + upload
- unpacking
- manifest basic flow
- printer integration spike

## Вхідні документи
- `../mobile-app-ios/docs/flutter-android-migration-plan.md`
- `../mobile-app-ios/docs/flutter-screen-mapping-and-backlog.md`
- `../mobile-app-ios/docs/mobile-screen-flow.md`
