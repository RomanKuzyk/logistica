class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiConfigurationException extends ApiException {
  const ApiConfigurationException(super.message);
}

class ApiTransportException extends ApiException {
  const ApiTransportException(super.message);
}

class ApiParsingException extends ApiException {
  const ApiParsingException(super.message);
}

class ApiBusinessException extends ApiException {
  const ApiBusinessException(super.message);
}
