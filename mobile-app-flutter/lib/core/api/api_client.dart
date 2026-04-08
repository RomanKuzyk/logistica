import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/core/api/api_signer.dart';
import 'package:mobile_app_flutter/core/api/api_time_formatter.dart';
import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';

class ApiClient {
  ApiClient({required AppConfig config, required AppLogger logger})
      : _config = config,
        _logger = logger,
        _signer = ApiSigner(config),
        _httpClient = http.Client();

  final AppConfig _config;
  final AppLogger _logger;
  final ApiSigner _signer;
  final http.Client _httpClient;

  AppLogger get logger => _logger;

  Future<List<Map<String, dynamic>>> execute({
    required String function,
    required String parameter,
  }) async {
    if (!_config.hasApiCredentials) {
      throw const ApiConfigurationException(
        'Не задані GC_API_USER / GC_API_PASSWORD / GC_API_SALT. Додай dart-define значення.',
      );
    }

    final Map<String, Object?> requestPayload = <String, Object?>{
      'time': formatLegacyApiTimestamp(DateTime.now()),
      'function': function,
      'parameters': parameter,
    };

    final String requestJson = jsonEncode(requestPayload);
    final Map<String, Object?> envelope = <String, Object?>{
      'user': _config.apiUser,
      'sign': _signer.signRequestJson(requestJson),
      'request': requestPayload,
    };

    final Uri uri = Uri.parse(_config.apiUrl);
    _logger.info('API RPC -> $function');

    final http.Response response;
    try {
      response = await _httpClient.post(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=utf-8'
        },
        body: jsonEncode(envelope),
      );
    } catch (error, stackTrace) {
      _logger.error('Transport error for $function',
          error: error, stackTrace: stackTrace);
      throw ApiTransportException('Transport error: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiTransportException(
          'HTTP ${response.statusCode}: ${response.body}');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (error, stackTrace) {
      _logger.error('Failed to decode JSON for $function',
          error: error, stackTrace: stackTrace);
      throw const ApiParsingException(
          'Не вдалося розібрати JSON-відповідь backend.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ApiParsingException(
          'Backend повернув неочікуваний JSON-формат.');
    }

    final bool successful = decoded['successful'] == true;
    if (!successful) {
      final Object? errorsStack = decoded['errorsstack'];
      final String message = switch (errorsStack) {
        String value => value,
        Map<String, dynamic> map =>
          (map['message'] ?? 'Unknown business error').toString(),
        _ => 'Unknown business error',
      };
      throw ApiBusinessException(message);
    }

    final Map<String, dynamic>? executed =
        decoded['executed'] as Map<String, dynamic>?;
    final Map<String, dynamic>? result =
        executed?['result'] as Map<String, dynamic>?;
    final Object? items = result?['Items'];

    if (items == null) {
      return <Map<String, dynamic>>[];
    }

    if (items is! List) {
      throw const ApiParsingException(
          'Backend повернув неочікуваний тип поля Items.');
    }

    return items.map((Object? item) {
      if (item is Map<String, dynamic>) {
        return item;
      }
      if (item is Map) {
        return item.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value));
      }
      throw const ApiParsingException('Елемент Items має неочікуваний формат.');
    }).toList();
  }

  void dispose() {
    _httpClient.close();
  }
}
