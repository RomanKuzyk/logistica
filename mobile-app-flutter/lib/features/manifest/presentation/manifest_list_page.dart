import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/manifest/data/manifest_repository.dart';
import 'package:mobile_app_flutter/features/manifest/domain/manifest.dart';
import 'package:mobile_app_flutter/features/manifest/presentation/manifest_scan_page.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class ManifestListPage extends StatefulWidget {
  const ManifestListPage({
    super.key,
    required this.services,
  });

  final AppServices services;

  @override
  State<ManifestListPage> createState() => _ManifestListPageState();
}

class _ManifestListPageState extends State<ManifestListPage> {
  late final ManifestRepository _repository;
  bool _loading = true;
  List<Manifest> _manifests = const <Manifest>[];

  @override
  void initState() {
    super.initState();
    _repository = ManifestRepository(apiClient: widget.services.apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<Manifest> manifests = await _repository.fetchOpenManifests();
      if (!mounted) {
        return;
      }
      setState(() {
        _manifests = manifests;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      await showLegacyAlertDialog(
        context,
        title: 'Atantion',
        message: 'Loading error : $error',
      );
    }
  }

  Future<void> _openManifest(Manifest manifest) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManifestScanPage(
          manifest: manifest,
          services: widget.services,
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(''),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _manifests.length,
              itemBuilder: (BuildContext context, int index) {
                final Manifest item = _manifests[index];
                return InkWell(
                  onTap: () => _openManifest(item),
                  child: Container(
                    color:
                        index.isEven ? const Color(0xFFEDEDF1) : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.number,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.dateTime,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
