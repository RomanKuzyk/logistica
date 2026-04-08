DART_DEFINES_FILE ?= config/dart_defines.local.json
APK_SOURCE := build/app/outputs/flutter-apk/app-debug.apk
APK_TARGET := build/gc-logistica.apk

.PHONY: apk analyze test doctor clean

apk:
	@if [ ! -f "$(DART_DEFINES_FILE)" ]; then \
		echo "Missing $(DART_DEFINES_FILE). Create it from config/dart_defines.example.json"; \
		exit 1; \
	fi
	./scripts/flutter-docker flutter pub get
	./scripts/flutter-docker flutter build apk --debug --dart-define-from-file=$(DART_DEFINES_FILE)
	mkdir -p build
	cp $(APK_SOURCE) $(APK_TARGET)
	@echo "APK ready: $(APK_TARGET)"

analyze:
	./scripts/flutter-docker flutter analyze

test:
	./scripts/flutter-docker flutter test

doctor:
	./scripts/flutter-docker flutter doctor -v

clean:
	rm -f $(APK_TARGET)
	./scripts/flutter-docker flutter clean
