.PHONY: apk flutter-analyze flutter-test flutter-doctor

apk:
	$(MAKE) -C mobile-app-flutter apk

flutter-analyze:
	$(MAKE) -C mobile-app-flutter analyze

flutter-test:
	$(MAKE) -C mobile-app-flutter test

flutter-doctor:
	$(MAKE) -C mobile-app-flutter doctor
