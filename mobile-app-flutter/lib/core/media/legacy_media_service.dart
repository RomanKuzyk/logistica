import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/media/aws_media_storage_service.dart';
import 'package:mobile_app_flutter/core/media/media_exceptions.dart';
import 'package:mobile_app_flutter/core/media/pending_media_upload.dart';
import 'package:mobile_app_flutter/core/media/pending_media_upload_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LegacyMediaService {
  LegacyMediaService({
    required AwsMediaStorageService storageService,
    required PendingMediaUploadStore uploadStore,
    required ApiClient apiClient,
    required AppLogger logger,
    ImagePicker? imagePicker,
  })  : _storageService = storageService,
        _uploadStore = uploadStore,
        _apiClient = apiClient,
        _logger = logger,
        _imagePicker = imagePicker ?? ImagePicker();

  final AwsMediaStorageService _storageService;
  final PendingMediaUploadStore _uploadStore;
  final ApiClient _apiClient;
  final AppLogger _logger;
  final ImagePicker _imagePicker;

  Future<String?> captureAndSavePhoto({
    required String idRef,
    required String typeIdRef,
  }) async {
    final XFile? captured = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (captured == null) {
      return null;
    }

    final Uint8List sourceBytes = await captured.readAsBytes();
    final Uint8List normalizedBytes = _normalizeToPng(sourceBytes);
    final String fileName = '${const Uuid().v4().toLowerCase()}.png';
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String localPath = '${documentsDirectory.path}/$fileName';
    await File(localPath).writeAsBytes(normalizedBytes, flush: true);

    final PendingMediaUpload upload = PendingMediaUpload(
      fileName: fileName,
      localPath: localPath,
      idRef: idRef,
      typeIdRef: typeIdRef,
    );
    await _uploadStore.upsert(upload);
    await _uploadPending(upload);
    return fileName;
  }

  Future<MediaSyncSummary> syncPendingUploads() async {
    int succeeded = 0;
    int failed = 0;
    final List<PendingMediaUpload> pending = _uploadStore.loadAll();
    for (final PendingMediaUpload upload in pending) {
      try {
        await _uploadPending(upload);
        succeeded += 1;
      } on MediaException catch (error, stackTrace) {
        _logger.warning(
          'Pending media upload failed: ${upload.fileName}',
          error: error,
          stackTrace: stackTrace,
        );
        failed += 1;
      }
    }

    return MediaSyncSummary(
      succeeded: succeeded,
      failed: failed,
      remaining: _uploadStore.loadAll().length,
    );
  }

  Future<void> _uploadPending(PendingMediaUpload upload) async {
    final File localFile = File(upload.localPath);
    if (!await localFile.exists()) {
      await _uploadStore.remove(upload.fileName);
      throw const MediaTransportException(
        'Локальний файл фото відсутній перед завантаженням.',
      );
    }

    await _storageService.uploadImageFile(
      localPath: upload.localPath,
      fileName: upload.fileName,
    );
    await _savePhoto(upload);

    if (await localFile.exists()) {
      await localFile.delete();
    }
    await _uploadStore.remove(upload.fileName);
  }

  Future<void> _savePhoto(PendingMediaUpload upload) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'SAVE_PHOTO',
      parameter:
          '{"IdRef":"${upload.idRef}","FileName":"${upload.fileName}","TypeIdRef":"${upload.typeIdRef}"}',
    );

    if (items.isEmpty) {
      throw const MediaBusinessException(
        'SAVE_PHOTO повернув порожній результат.',
      );
    }

    final Map<String, dynamic> row = items.first;
    final int errorCode = int.tryParse(row['Error']?.toString() ?? '') ?? 0;
    if (errorCode != 0) {
      throw MediaBusinessException(
          row['ErrorsDetail']?.toString() ?? 'SAVE_PHOTO error');
    }
  }

  Uint8List _normalizeToPng(Uint8List bytes) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const MediaTransportException(
        'Не вдалося розпізнати зняте фото перед збереженням.',
      );
    }
    final img.Image resized =
        decoded.width > 1024 ? img.copyResize(decoded, width: 1024) : decoded;
    return Uint8List.fromList(img.encodePng(resized));
  }
}
