import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String? _report;
  bool _busy = false;

  Future<void> _generate() async {
    setState(() => _busy = true);
    final r = await ApiService.instance.generateInsights();
    if (!mounted) return;
    setState(() {
      _report = r;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        HoverCard(
          gradient: AppTheme.headerGradient,
          showBorder: false,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: const Text('POST-EVENT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Text('Your Cisco Live recap',
                  style: text.headlineSmall
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              const Text(
                'Summarise sessions, contacts, and follow-ups from your week in Las Vegas.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _busy ? null : _generate,
                icon: _busy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome, size: 16),
                label: Text(_busy ? 'Generating…' : 'Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _StatTile(
                    icon: Icons.event_available,
                    label: 'Sessions',
                    value: '12',
                    color: AppTheme.primary)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatTile(
                    icon: Icons.people_alt_outlined,
                    label: 'Contacts',
                    value: '6',
                    color: AppTheme.success)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatTile(
                    icon: Icons.hub_outlined,
                    label: 'Channels',
                    value: '16',
                    color: AppTheme.warning)),
          ],
        ),
        const SizedBox(height: 12),
        HoverCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text('Generated report',
                      style: text.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              if (_report == null)
                Text(
                  'No insights yet. Tap Generate Report to synthesise your week.',
                  style: text.bodyMedium,
                )
              else
                Text(_report!, style: text.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.muted)),
        ],
      ),
    );
  }
}
