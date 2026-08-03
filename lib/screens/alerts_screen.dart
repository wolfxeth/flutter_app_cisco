import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/alert_item.dart';
import '../theme.dart';
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

  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('nearby')) return Icons.location_on_outlined;
    if (t.contains('session')) return Icons.event_available_outlined;
    if (t.contains('meeting')) return Icons.calendar_today_outlined;
    return Icons.notifications_outlined;
  }

  Color _colorFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('nearby')) return AppTheme.primary;
    if (t.contains('filling')) return AppTheme.warning;
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FutureBuilder<List<AlertItem>>(
      future: _alertsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final alerts = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            HoverCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_outlined,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Alerts', style: text.titleLarge),
                        const SizedBox(height: 4),
                        Text('${alerts.length} updates from your schedule',
                            style: text.bodySmall),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() =>
                          _alertsFuture = ApiService.instance.getAlerts());
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...alerts.map((a) {
              final color = _colorFor(a.title);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HoverCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_iconFor(a.title),
                            color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(a.title,
                                      style: text.titleMedium),
                                ),
                                Text('3:58 PM',
                                    style: text.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(a.message, style: text.bodyMedium),
                            const SizedBox(height: 12),
                            Row(children: [
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Dismissed')));
                                },
                                child: const Text('Dismiss'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Meet now')));
                                },
                                child: const Text('Meet now'),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
