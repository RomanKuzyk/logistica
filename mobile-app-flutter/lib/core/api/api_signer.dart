import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mobile_app_flutter/core/config/app_config.dart';

class ApiSigner {
  const ApiSigner(this._config);

  final AppConfig _config;

  String signRequestJson(String requestJson) {
    final String payload = '${_config.apiUser}${_config.apiPassword}$requestJson${_config.apiSalt}';
    return md5.convert(utf8.encode(payload)).toString();
  }
}
