import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/manifest/presentation/manifest_scan_page.dart';

class ManifestListPage extends StatelessWidget {
  const ManifestListPage({super.key});

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
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ManifestScanPage(
                    manifestNumber: '00001718',
                  ),
                ),
              );
            },
            child: Container(
              color: const Color(0xFFEDEDF1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '00001718',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '2026-04-06T16:44:21.000Z',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
