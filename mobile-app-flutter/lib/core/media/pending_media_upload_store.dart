import 'package:mobile_app_flutter/core/media/pending_media_upload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingMediaUploadStore {
  static const String pendingUploadsKey = 'gc_pending_media_uploads';

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefs {
    final SharedPreferences? prefs = _preferences;
    if (prefs == null) {
      throw StateError(
        'PendingMediaUploadStore.init() must be called before use.',
      );
    }
    return prefs;
  }

  List<PendingMediaUpload> loadAll() {
    final List<String> items =
        _prefs.getStringList(pendingUploadsKey) ?? <String>[];
    return items.map(PendingMediaUpload.decode).toList();
  }

  Future<void> upsert(PendingMediaUpload upload) async {
    final List<PendingMediaUpload> current = loadAll();
    final int existingIndex = current.indexWhere(
        (PendingMediaUpload item) => item.fileName == upload.fileName);
    if (existingIndex >= 0) {
      current[existingIndex] = upload;
    } else {
      current.add(upload);
    }
    await _saveAll(current);
  }

  Future<void> remove(String fileName) async {
    final List<PendingMediaUpload> current = loadAll()
      ..removeWhere((PendingMediaUpload item) => item.fileName == fileName);
    await _saveAll(current);
  }

  Future<void> _saveAll(List<PendingMediaUpload> items) async {
    await _prefs.setStringList(
      pendingUploadsKey,
      items.map((PendingMediaUpload item) => item.encode()).toList(),
    );
  }
}
