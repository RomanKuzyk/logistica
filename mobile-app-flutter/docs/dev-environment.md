# Dev Environment

## Підхід
Для `mobile-app-flutter` рекомендовано розділяти:
- **host environment** — редактор, емулятор, `adb`, фізичні девайси, інтерактивна розробка;
- **docker environment** — відтворюваний build/test/lint runtime для Flutter Android.

## Чому не тільки Docker
Docker добре підходить для:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk`

Але Docker незручний для:
- Android emulator
- робота з фізичними девайсами
- інтерактивний hot reload/hot restart як primary workflow
- camera / scanner / printer hardware verification

## Рекомендована модель роботи
### Host
- Android Studio або VS Code
- Android SDK / emulator
- `adb`
- фізичний Android device

### Docker
- reproducible Flutter toolchain
- CI-compatible build environment
- локальний smoke build без залежності від host Flutter installation

## Файли
- `docker/Dockerfile`
- `docker-compose.yml`

## Команди
### Підготувати локальний config file
```bash
cp config/dart_defines.example.json config/dart_defines.local.json
```

У локальному файлі мають бути:
- API contract variables:
  - `GC_API_URL`
  - `GC_API_USER`
  - `GC_API_PASSWORD`
  - `GC_API_SALT`
- AWS media variables:
  - `GC_AWS_REGION`
  - `GC_AWS_IDENTITY_POOL_ID`
  - `GC_AWS_STORAGE_BUCKET`

### Відкрити shell у контейнері
```bash
docker compose run --rm flutter
```

або через helper:
```bash
./scripts/flutter-docker bash
```

### Перевірити toolchain
```bash
docker compose run --rm flutter flutter doctor -v
```

або:
```bash
./scripts/flutter-docker flutter doctor -v
```

### Завантажити залежності
```bash
docker compose run --rm flutter flutter pub get
```

### Аналіз
```bash
docker compose run --rm flutter flutter analyze
```

### Тести
```bash
docker compose run --rm flutter flutter test
```

### Android APK build
```bash
docker compose run --rm flutter flutter build apk
```

### Запуск з local dart defines
```bash
./scripts/flutter-docker flutter run \
  --dart-define-from-file=config/dart_defines.local.json
```

### Локальна compile-перевірка з defines
```bash
./scripts/flutter-docker flutter build apk --debug \
  --dart-define-from-file=config/dart_defines.local.json
```

## Host prerequisites
Для реальної Android розробки все одно потрібні:
- `adb`
- Android SDK / emulator
- JDK сумісної версії

## Статус у цьому workspace
- `adb` уже доступний на host.
- Flutter SDK на host наразі відсутній.
- Docker доступний, тому перший reproducible build path вже підготовлено.
- Compose-based `pub get`, `analyze` і `test` уже підтверджені як робочі.
