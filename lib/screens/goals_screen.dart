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
  late Future<List<dynamic>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _goalsFuture = ApiService.instance.getGoals();
  }

  Future<void> _toggle(String id) async {
    await ApiService.instance.toggleGoalDone(id);
    setState(() {
      _goalsFuture = ApiService.instance.getGoals();
    });
  }

  Future<void> _delete(String id) async {
    await ApiService.instance.deleteGoal(id);
    setState(() {
      _goalsFuture = ApiService.instance.getGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<dynamic>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final goals = snapshot.data ?? [];
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Persona', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))]),
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    const Icon(Icons.person_outline, color: AppTheme.primary, size: 32),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Network Engineer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Infrastructure & Operations', style: TextStyle(color: AppTheme.muted))])),
                  ]),
                ),
                const SizedBox(height: 18),
                const Text('Pre-Event Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...goals.map((g) => HoverCard(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9F4F8)),
                  padding: const EdgeInsets.all(16),
                  color: g['done'] == true ? const Color(0xFFEFF9FD) : Colors.white,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(
                        child: Row(children: [
                          Checkbox(value: g['done'] == true, onChanged: (_) => _toggle(g['id'])),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              g['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: g['done'] == true ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      TextButton(onPressed: () => _delete(g['id']), child: const Text('Delete'))
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      g['description'] ?? '',
                      style: TextStyle(
                        color: AppTheme.muted,
                        decoration: g['done'] == true ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ]),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
