import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import '../models/contact.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = ApiService.instance.getNotes();
  }

  Future<void> _delete(String id) async {
    await ApiService.instance.deleteNote(id);
    setState(() {
      _notesFuture = ApiService.instance.getNotes();
    });
  }

  Future<void> _create() async {
    await ApiService.instance.createNote('New Note', 'Describe meeting notes here.');
    setState(() {
      _notesFuture = ApiService.instance.getNotes();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note created')));
  }

  Future<void> _editNote(Note note) async {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: 'Body',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.black87),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    await ApiService.instance.updateNote(note.id, titleController.text, bodyController.text);
    setState(() {
      _notesFuture = ApiService.instance.getNotes();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final notes = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('Meeting Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: _create, child: const Text('+ New'))
              ]),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: notes.map((n) => HoverCard(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Text(n.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          OutlinedButton(onPressed: () => _editNote(n), child: const Text('Edit')),
                          OutlinedButton(onPressed: () => _delete(n.id), child: const Text('Delete'))
                        ])
                      ]),
                      const SizedBox(height: 12),
                      Text(n.body, style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.muted)),
                      const SizedBox(height: 14),
                      Text(n.timestamp ?? '', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ]),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Saved Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Contact>>(
                    future: ApiService.instance.getContacts(),
                    builder: (ctx, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();
                      final saved = snap.data!.where((c) => c.saved).toList();
                      if (saved.isEmpty) return const Text('No saved contacts', style: TextStyle(color: AppTheme.muted));
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: saved.map((c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('${c.name} · ${c.title}', style: const TextStyle(color: AppTheme.muted)))).toList());
                    },
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
