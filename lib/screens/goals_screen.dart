import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  static const List<String> _categories = [
    'Learning',
    'Networking',
    'Strategy',
    'Vendor Meeting',
    'Planning',
  ];
  static const List<String> _priorities = ['Low', 'Medium', 'High'];

  List<Map<String, dynamic>> _personas = const [];
  List<Map<String, dynamic>> _goals = const [];
  String? _selectedPersonaId;
  bool _loading = true;
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final personas = await ApiService.instance.getPersonas();
    final selected =
        personas.isNotEmpty ? personas.first['id'] as String : null;
    final goals = selected == null
        ? <Map<String, dynamic>>[]
        : await ApiService.instance.getGoals(selected);
    if (!mounted) return;
    setState(() {
      _personas = personas;
      _selectedPersonaId = selected;
      _goals = goals;
      _loading = false;
    });
  }

  Future<void> _selectPersona(String id) async {
    if (id == _selectedPersonaId) return;
    setState(() {
      _selectedPersonaId = id;
      _showAddForm = false;
    });
    final goals = await ApiService.instance.getGoals(id);
    if (!mounted) return;
    setState(() => _goals = goals);
  }

  Future<void> _reloadGoals() async {
    if (_selectedPersonaId == null) return;
    final goals = await ApiService.instance.getGoals(_selectedPersonaId!);
    if (!mounted) return;
    setState(() => _goals = goals);
  }

  Future<void> _toggle(String id) async {
    if (_selectedPersonaId == null) return;
    await ApiService.instance.toggleGoalDone(_selectedPersonaId!, id);
    await _reloadGoals();
  }

  Future<void> _delete(String id) async {
    if (_selectedPersonaId == null) return;
    await ApiService.instance.deleteGoal(_selectedPersonaId!, id);
    await _reloadGoals();
  }

  Map<String, dynamic>? get _selectedPersona {
    for (final p in _personas) {
      if (p['id'] == _selectedPersonaId) return p;
    }
    return null;
  }

  int get _doneCount =>
      _goals.where((g) => g['done'] == true).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final persona = _selectedPersona;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPersonaCard(),
        const SizedBox(height: 18),
        _buildPreEventHeader(persona),
        const SizedBox(height: 10),
        if (_showAddForm) _AddGoalForm(
          categories: _categories,
          priorities: _priorities,
          onCancel: () => setState(() => _showAddForm = false),
          onSave: _handleSaveNewGoal,
        ),
        if (_showAddForm) const SizedBox(height: 10),
        ..._goals.map(_buildGoalCard),
      ],
    );
  }

  Widget _buildPersonaCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Persona',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Helps tailor session and meeting recommendations',
              style: TextStyle(color: AppTheme.muted, fontSize: 13)),
          const SizedBox(height: 14),
          ..._personas.map(_buildPersonaOption),
        ],
      ),
    );
  }

  Widget _buildPersonaOption(Map<String, dynamic> p) {
    final selected = p['id'] == _selectedPersonaId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectPersona(p['id'] as String),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF9FD) : Colors.white,
            border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFE1E8EF),
              width: selected ? 1.6 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name']?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(p['subtitle']?.toString() ?? '',
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreEventHeader(Map<String, dynamic>? persona) {
    final name = persona?['name']?.toString() ?? '';
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pre-Event Goals',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('$name · $_doneCount/${_goals.length} complete',
                    style:
                        const TextStyle(color: AppTheme.muted, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: Icon(_showAddForm ? Icons.close : Icons.add, size: 18),
            label: Text(_showAddForm ? 'Close' : 'Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> g) {
    final done = g['done'] == true;
    final techs =
        (g['technologies'] as List?)?.map((t) => t.toString()).toList() ??
            const <String>[];
    return HoverCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9F4F8)),
      padding: const EdgeInsets.all(16),
      color: done ? const Color(0xFFEFF9FD) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                        value: done,
                        onChanged: (_) => _toggle(g['id'].toString())),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        g['title']?.toString() ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () => _delete(g['id'].toString()),
                  child: const Text('Delete')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            g['description']?.toString() ?? '',
            style: TextStyle(
              color: AppTheme.muted,
              decoration:
                  done ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          if (g['category'] != null || g['priority'] != null || techs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (g['category'] != null)
                  _MetaChip(label: g['category'].toString()),
                if (g['priority'] != null)
                  _MetaChip(
                    label: g['priority'].toString(),
                    color: _priorityColor(g['priority'].toString()),
                  ),
                ...techs.map((t) => _MetaChip(label: t, subtle: true)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFE53935);
      case 'Medium':
        return const Color(0xFFEF9F1A);
      default:
        return AppTheme.muted;
    }
  }

  Future<void> _handleSaveNewGoal({
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> technologies,
  }) async {
    if (_selectedPersonaId == null) return;
    await ApiService.instance.createGoal(
      _selectedPersonaId!,
      title: title,
      description: description,
      category: category,
      priority: priority,
      technologies: technologies,
    );
    if (!mounted) return;
    setState(() => _showAddForm = false);
    await _reloadGoals();
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppTheme.primary : const Color(0xFFB7C4D2),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.color, this.subtle = false});
  final String label;
  final Color? color;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: subtle ? 0.08 : 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: base),
      ),
    );
  }
}

typedef _SaveGoalFn = Future<void> Function({
  required String title,
  required String description,
  required String category,
  required String priority,
  required List<String> technologies,
});

class _AddGoalForm extends StatefulWidget {
  const _AddGoalForm({
    required this.categories,
    required this.priorities,
    required this.onCancel,
    required this.onSave,
  });

  final List<String> categories;
  final List<String> priorities;
  final VoidCallback onCancel;
  final _SaveGoalFn onSave;

  @override
  State<_AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<_AddGoalForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  late String _category = widget.categories.first;
  late String _priority = widget.priorities[1]; // Medium
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _techCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }
    setState(() => _saving = true);
    final techs = _techCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await widget.onSave(
      title: title,
      description: _descCtrl.text.trim(),
      category: _category,
      priority: _priority,
      technologies: techs,
    );
    if (!mounted) return;
    setState(() => _saving = false);
  }

  InputDecoration _fieldDecoration() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCFD8E3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCFD8E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
        ),
      );

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        child: Text(s,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8EF)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Title'),
          TextField(controller: _titleCtrl, decoration: _fieldDecoration()),
          _label('Description'),
          TextField(
              controller: _descCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: _fieldDecoration()),
          _label('Category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _fieldDecoration(),
            items: widget.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          _label('Priority'),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: _fieldDecoration(),
            items: widget.priorities
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _priority = v ?? _priority),
          ),
          _label('Technologies (comma-separated)'),
          TextField(
              controller: _techCtrl,
              decoration: _fieldDecoration().copyWith(
                  hintText: 'e.g. ZTNA, Nexus, GPU')),
          const SizedBox(height: 18),
          Row(children: [
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Goal'),
            ),
            const SizedBox(width: 10),
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
