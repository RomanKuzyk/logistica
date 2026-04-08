FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /workspace

ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PUB_CACHE=/sdks/.pub-cache
ENV GRADLE_USER_HOME=/root/.gradle
ENV CI=true

RUN yes | sdkmanager --licenses >/dev/null
RUN sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;35.0.0" \
    "ndk;28.2.13676358" \
    "platforms;android-35" \
    "cmake;3.22.1"

CMD ["bash"]
