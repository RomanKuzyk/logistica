import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/media/media_exceptions.dart';

class AwsMediaStorageService {
  AwsMediaStorageService({
    required AppConfig config,
    required AppLogger logger,
  })  : _config = config,
        _logger = logger;

  final AppConfig _config;
  final AppLogger _logger;

  bool _configured = false;

  Future<void> ensureConfigured() async {
    if (_configured) {
      return;
    }
    if (!_config.hasAwsStorageConfig) {
      throw const MediaConfigurationException(
        'AWS S3 конфігурація відсутня у dart-define.',
      );
    }

    try {
      if (!Amplify.isConfigured) {
        await Amplify.addPlugins(<AmplifyPluginInterface>[
          AmplifyAuthCognito(),
          AmplifyStorageS3(),
        ]);
        await Amplify.configure(_buildAmplifyConfig());
      }

      await Amplify.Auth.fetchAuthSession();
      _configured = true;
    } on AmplifyAlreadyConfiguredException {
      _configured = true;
    } on AuthException catch (error, stackTrace) {
      _logger.error(
        'AWS auth session bootstrap failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MediaTransportException(error.message);
    } on StorageException catch (error, stackTrace) {
      _logger.error(
        'AWS storage bootstrap failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MediaTransportException(error.message);
    } on Exception catch (error, stackTrace) {
      _logger.error(
        'Amplify configure failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MediaTransportException(error.toString());
    }
  }

  Future<void> uploadImageFile({
    required String localPath,
    required String fileName,
  }) async {
    await ensureConfigured();
    try {
      await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(localPath),
        path: StoragePath.fromString(fileName),
        options: const StorageUploadFileOptions(
          pluginOptions: S3UploadFilePluginOptions(getProperties: true),
        ),
      ).result;
    } on StorageException catch (error, stackTrace) {
      _logger.error(
        'AWS image upload failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MediaTransportException(error.message);
    }
  }

  String _buildAmplifyConfig() {
    return jsonEncode(<String, Object>{
      'version': '1',
      'auth': <String, Object>{
        'aws_region': _config.awsRegion,
        'identity_pool_id': _config.awsIdentityPoolId,
        'unauthenticated_identities_enabled': true,
      },
      'storage': <String, Object>{
        'aws_region': _config.awsRegion,
        'bucket_name': _config.awsStorageBucket,
      },
    });
  }
}
