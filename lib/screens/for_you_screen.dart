import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = ApiService.instance.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final contacts = snapshot.data ?? [];
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, i) {
              final c = contacts[i];
              return HoverCard(
                margin: const EdgeInsets.symmetric(vertical: 10),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${c.title} · ${c.company}', style: const TextStyle(color: AppTheme.muted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFE6F7FF), borderRadius: BorderRadius.circular(10)),
                          child: Text('${c.distanceMeters ?? 0}m', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Automating a 200-site campus refresh. Wants to meet other automation practitioners.', style: TextStyle(color: AppTheme.muted)),
                    const SizedBox(height: 12),
                    Text('CURRENT LOCATION', style: TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(c.currentLocation ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final saved = await ApiService.instance.toggleSaveContact(c.id);
                              if (!mounted) return;
                              setState(() {
                                _contactsFuture = ApiService.instance.getContacts();
                              });
                              messenger.showSnackBar(SnackBar(content: Text(saved ? 'Saved' : 'Removed')));
                            },
                            child: Text(c.saved ? 'Saved' : 'Save Contact'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await ApiService.instance.scheduleMeeting(c.id);
                              if (!mounted) return;
                              messenger.showSnackBar(const SnackBar(content: Text('Meeting scheduled')));
                            },
                            child: const Text('Schedule Meeting'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
