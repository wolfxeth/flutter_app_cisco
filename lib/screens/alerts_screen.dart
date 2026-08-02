import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/alert_item.dart';
import '../widgets/hover_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<AlertItem>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = ApiService.instance.getAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FutureBuilder<List<AlertItem>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: \\${snapshot.error}'));
          final alerts = snapshot.data ?? [];
          return ListView(
            children: alerts.map((a) => HoverCard(
              margin: const EdgeInsets.symmetric(vertical: 10),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:6), Text(a.message), const SizedBox(height:6), const Text('3:58 PM', style: TextStyle(fontSize: 12, color: Colors.grey))])),
                ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meet now'))); }, child: const Text('Meet now'))
              ]),
            )).toList(),
          );
        },
      ),
    );
  }
}
