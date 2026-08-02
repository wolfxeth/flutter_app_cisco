import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String? _report;

  Future<void> _generate() async {
    final r = await ApiService.instance.generateInsights();
    setState(() => _report = r);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Post-Event Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _generate, child: const Text('Generate Report')),
          const SizedBox(height: 12),
          if (_report != null) Expanded(child: SingleChildScrollView(child: Text(_report!))) else const Text('No insights yet.')
        ],
      ),
    );
  }
}
