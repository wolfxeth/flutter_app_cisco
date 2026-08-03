import 'package:flutter/material.dart';
import 'screens/goals_screen.dart';
import 'screens/for_you_screen.dart';
import 'screens/webex_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/insights_screen.dart';
import 'widgets/bottom_nav.dart';

import 'theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const GoalsScreen(),
    const ForYouScreen(),
    const WebexScreen(),
    const NearbyScreen(),
    const NotesScreen(),
    const AlertsScreen(),
    const InsightsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cisco Live Notes',
      theme: AppTheme.light(),
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          toolbarHeight: 100,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.headerBg, Color(0xFF0D1F34)]),
            ),
          ),
          title: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Cisco Live Las Vegas 2026', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Event dashboard and note planner', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              );

              final badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))]),
                child: const Text('Network Engineer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: titleBlock),
                      if (!isCompact) ...[
                        const SizedBox(width: 12),
                        badge,
                      ]
                    ],
                  ),
                  if (isCompact) ...[
                    const SizedBox(height: 12),
                    badge,
                  ],
                ],
              );
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF0F2435), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 10))]),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      hintText: 'Ask anything...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNav(selectedIndex: _selectedIndex, onTap: _onItemTapped),
      ),
    );
  }
}
