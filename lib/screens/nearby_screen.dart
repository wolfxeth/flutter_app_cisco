import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import '../widgets/hover_card.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
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
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: \\${snapshot.error}'));
          final contacts = snapshot.data ?? [];
          // Sort by distance if available
          contacts.sort((a, b) => (a.distanceMeters ?? 9999).compareTo(b.distanceMeters ?? 9999));
          return ListView(
            children: contacts.map((c) => HoverCard(
              margin: const EdgeInsets.symmetric(vertical: 10),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(c.name),
                subtitle: Text(c.currentLocation ?? ''),
                trailing: Text('${c.distanceMeters ?? 0}m'),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}
