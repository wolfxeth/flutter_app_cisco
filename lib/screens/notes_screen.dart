import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import '../models/session.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = const [];
  List<Session> _sessions = const [];
  List<Map<String, dynamic>> _saved = const [];
  bool _loading = true;
  bool _showForm = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final notes = await ApiService.instance.getNotes();
      final sessions = await ApiService.instance.getSessions();
      final saved = await ApiService.instance.getSavedContacts();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _sessions = sessions;
        _saved = saved;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('NotesScreen load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    await ApiService.instance.deleteNote(id);
    await _load();
  }

  Future<void> _handleSaveNewNote({
    required String title,
    required String body,
    required String? linkedSessionId,
    required List<String> participants,
  }) async {
    await ApiService.instance.createNote(
      title.isEmpty ? 'Untitled note' : title,
      body,
      linkedSessionId: linkedSessionId,
      participants: participants,
    );
    if (!mounted) return;
    setState(() => _showForm = false);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note saved')));
  }

  Future<void> _editNote(Note note) async {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    await ApiService.instance.updateNote(
        note.id, titleController.text, bodyController.text);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note updated')));
  }

  List<Note> get _filteredNotes {
    if (_search.trim().isEmpty) return _notes;
    final q = _search.toLowerCase();
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        if (_showForm)
          _NewNoteForm(
            sessions: _sessions,
            savedContacts: _saved,
            onCancel: () => setState(() => _showForm = false),
            onSave: _handleSaveNewNote,
          )
        else ...[
          ..._filteredNotes.map(_noteCard),
          const SizedBox(height: 4),
          _savedContactsCard(),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader() {
    final text = Theme.of(context).textTheme;
    return HoverCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meeting Notes', style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text('${_notes.length} notes · ${_saved.length} saved contacts',
                      style: text.bodySmall),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showForm = !_showForm),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: Icon(_showForm ? Icons.close : Icons.add, size: 16),
              label: Text(_showForm ? 'Close' : 'New'),
            ),
          ]),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Search notes, transcripts, contacts…',
              prefixIcon: Icon(Icons.search,
                  size: 18, color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard(Note n) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(n.title, style: text.titleMedium)),
                const SizedBox(width: 8),
                Wrap(spacing: 8, children: [
                  OutlinedButton(
                      onPressed: () => _editNote(n),
                      child: const Text('Edit')),
                  OutlinedButton(
                    onPressed: () => _delete(n.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side:
                          const BorderSide(color: AppTheme.danger, width: 1.2),
                    ),
                    child: const Text('Delete'),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 10),
            Text(n.body,
                style: text.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.schedule, size: 12, color: AppTheme.muted),
              const SizedBox(width: 4),
              Text(_formatTimestamp(n.timestamp), style: text.bodySmall),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _savedContactsCard() {
    final text = Theme.of(context).textTheme;
    return HoverCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.contact_page_outlined,
                size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text('Saved Contacts', style: text.titleMedium),
          ]),
          const SizedBox(height: 10),
          if (_saved.isEmpty)
            Text('No saved contacts', style: text.bodyMedium)
          else
            ..._saved.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${c['name']} · ${c['title']} · ${c['company']}',
                    style: text.bodyMedium,
                  ),
                )),
        ],
      ),
    );
  }

  String _formatTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final m = dt.month.toString();
    final d = dt.day.toString();
    final y = (dt.year % 100).toString().padLeft(2, '0');
    var hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$m/$d/$y, $hour:$min $ampm';
  }
}

typedef _SaveNoteFn = Future<void> Function({
  required String title,
  required String body,
  required String? linkedSessionId,
  required List<String> participants,
});

class _NewNoteForm extends StatefulWidget {
  const _NewNoteForm({
    required this.sessions,
    required this.savedContacts,
    required this.onCancel,
    required this.onSave,
  });

  final List<Session> sessions;
  final List<Map<String, dynamic>> savedContacts;
  final VoidCallback onCancel;
  final _SaveNoteFn onSave;

  @override
  State<_NewNoteForm> createState() => _NewNoteFormState();
}

class _NewNoteFormState extends State<_NewNoteForm> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String? _linkedSessionId;
  final Set<String> _participants = {};
  bool _recording = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        child: Text(s,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
                letterSpacing: 0.3)),
      );

  Future<void> _pickParticipants() async {
    final picked = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final local = Set<String>.from(_participants);
        return StatefulBuilder(builder: (ctx, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add participants',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Select from your saved contacts',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.muted)),
                  const SizedBox(height: 8),
                  ...widget.savedContacts.map((c) {
                    final id = c['id'].toString();
                    final selected = local.contains(id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) => setModalState(() {
                        selected ? local.remove(id) : local.add(id);
                      }),
                      title: Text(c['name']?.toString() ?? ''),
                      subtitle: Text(
                          '${c['title']} · ${c['company']}',
                          style: const TextStyle(color: AppTheme.muted)),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(local),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    if (picked == null) return;
    setState(() {
      _participants
        ..clear()
        ..addAll(picked);
    });
  }

  String _participantName(String id) {
    for (final c in widget.savedContacts) {
      if (c['id'].toString() == id) return c['name']?.toString() ?? id;
    }
    return id;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      linkedSessionId: _linkedSessionId,
      participants: _participants.toList(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
  }

  void _fakeRecording() {
    setState(() => _recording = !_recording);
    if (_recording) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording started (demo)')));
    } else {
      _bodyCtrl.text = _bodyCtrl.text.isEmpty
          ? 'Auto-transcript: discussed Zero Trust rollout plans and next steps.'
          : '${_bodyCtrl.text}\nAuto-transcript: additional notes captured from voice.';
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording stopped — transcript added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return HoverCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Meeting Note', style: text.titleLarge),
          _label('Title'),
          TextField(controller: _titleCtrl),
          _label('Linked Session'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _linkedSessionId,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.muted),
                hint: const Text('None'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('None')),
                  ...widget.sessions.map((s) => DropdownMenuItem<String?>(
                        value: s.id,
                        child: Text('${s.id} · ${s.title}',
                            overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (v) => setState(() => _linkedSessionId = v),
              ),
            ),
          ),
          _label('Voice Capture'),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fakeRecording,
              icon: Icon(_recording ? Icons.stop_circle : Icons.mic,
                  size: 18),
              label: Text(_recording ? 'Stop Recording' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _recording
                    ? AppTheme.danger
                    : AppTheme.headerDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          _label('Additional Notes'),
          TextField(
            controller: _bodyCtrl,
            minLines: 3,
            maxLines: 6,
          ),
          _label('Participants'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._participants.map((id) => Chip(
                    label: Text(_participantName(id)),
                    onDeleted: () =>
                        setState(() => _participants.remove(id)),
                    backgroundColor: AppTheme.accentSoft,
                    side: const BorderSide(color: AppTheme.border),
                    labelStyle: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  )),
              OutlinedButton.icon(
                onPressed: _pickParticipants,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Contact'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('AI summary generated (demo)')));
              },
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('AI Summary & Takeaways'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.headerDeep,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Note'),
            ),
            OutlinedButton(
              onPressed: _saving ? null : widget.onCancel,
              child: const Text('Cancel'),
            ),
          ]),
        ],
      ),
    );
  }
}
