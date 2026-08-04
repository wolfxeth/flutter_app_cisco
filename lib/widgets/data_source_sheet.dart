import 'package:flutter/material.dart';
import '../config.dart';
import '../theme.dart';

/// Bottom sheet that lets anyone switch between the offline dummy data and the
/// live backend at runtime, and point the app at a different API base URL.
Future<void> showDataSourceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _DataSourceSheet(),
  );
}

class _DataSourceSheet extends StatefulWidget {
  const _DataSourceSheet();

  @override
  State<_DataSourceSheet> createState() => _DataSourceSheetState();
}

class _DataSourceSheetState extends State<_DataSourceSheet> {
  late bool _useDummy = AppConfig.useDummy.value;
  late final TextEditingController _urlController =
      TextEditingController(text: AppConfig.baseUrl.value);

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    await AppConfig.setBaseUrl(_urlController.text);
    await AppConfig.setUseDummy(_useDummy);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_useDummy
            ? 'Using offline demo data'
            : 'Using live API · ${AppConfig.baseUrl.value}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Data source',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Switch between the built-in demo data and the live backend. '
            'Demo data works even when the server is offline.',
            style: TextStyle(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile.adaptive(
              value: _useDummy,
              activeThumbColor: AppTheme.accent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              title: const Text(
                'Use demo data (offline)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: Text(
                _useDummy ? 'DEMO · assets/dummy/data.json' : 'LIVE · calls the API',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),
              onChanged: (v) => setState(() => _useDummy = v),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'API base URL',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _urlController,
            enabled: !_useDummy,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'http://10.0.2.2:8080',
              isDense: true,
              filled: true,
              fillColor: _useDummy ? const Color(0xFFEDEDED) : const Color(0xFFF3F6FA),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Android emulator → 10.0.2.2  ·  iOS sim / desktop → localhost  ·  '
            'real device → your PC\'s LAN IP (e.g. 192.168.x.x)',
            style: TextStyle(fontSize: 10.5, color: Colors.black.withValues(alpha: 0.45)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _apply,
              child: const Text(
                'Apply',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
