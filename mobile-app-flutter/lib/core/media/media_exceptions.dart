class MediaException implements Exception {
  const MediaException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MediaConfigurationException extends MediaException {
  const MediaConfigurationException(super.message);
}

class MediaTransportException extends MediaException {
  const MediaTransportException(super.message);
}

class MediaBusinessException extends MediaException {
  const MediaBusinessException(super.message);
}

class MediaCancelledException extends MediaException {
  const MediaCancelledException()
      : super('Користувач скасував створення фото.');
}
