import 'package:flutter/material.dart';
import 'config.dart';
import 'screens/goals_screen.dart';
import 'screens/for_you_screen.dart';
import 'screens/webex_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/insights_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/data_source_sheet.dart';

import 'theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  /// Bumped whenever the data source changes so the visible screen rebuilds
  /// from scratch and re-fetches against the new source.
  int _reloadToken = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildScreens();
    AppConfig.useDummy.addListener(_onDataSourceChanged);
    AppConfig.baseUrl.addListener(_onDataSourceChanged);
  }

  @override
  void dispose() {
    AppConfig.useDummy.removeListener(_onDataSourceChanged);
    AppConfig.baseUrl.removeListener(_onDataSourceChanged);
    super.dispose();
  }

  void _buildScreens() {
    _screens = <Widget>[
      const GoalsScreen(),
      ForYouScreen(onOpenWebex: () => _onItemTapped(2)),
      const WebexScreen(),
      const NearbyScreen(),
      const NotesScreen(),
      const AlertsScreen(),
      const InsightsScreen(),
    ];
  }

  void _onDataSourceChanged() {
    setState(() {
      _reloadToken++;
      _buildScreens();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const _AppHeader(),
      body: KeyedSubtree(
        key: ValueKey(_reloadToken),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar:
          BottomNav(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AppHeader();

  @override
  Size get preferredSize => const Size.fromHeight(190);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _CiscoLiveWordmark(),
                    const SizedBox(width: 12),
                    if (!compact) const _EventTag(),
                    const Spacer(),
                    const _DataSourceButton(),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'Cisco Live Las Vegas 2026',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        _PersonaBadge(),
                      ],
                    ),
                  ],
                ),
                if (compact) ...[
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: _EventTag(),
                  ),
                ],
                const SizedBox(height: 14),
                const _HeaderSearchBar(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DataSourceButton extends StatelessWidget {
  const _DataSourceButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppConfig.useDummy,
      builder: (context, useDummy, _) {
        final label = useDummy ? 'DEMO' : 'LIVE';
        final color = useDummy ? Colors.white70 : AppTheme.accent;
        return InkWell(
          onTap: () => showDataSourceSheet(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.settings, size: 13, color: color),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CiscoLiveWordmark extends StatelessWidget {
  const _CiscoLiveWordmark();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_bar(6), _bar(11), _bar(14), _bar(11), _bar(6)],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              'CISCO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Live!',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bar(double h) => Container(
        width: 4,
        height: h,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

class _EventTag extends StatelessWidget {
  const _EventTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const Text(
        'Las Vegas, NV  ·  June 8-15, 2027',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PersonaBadge extends StatelessWidget {
  const _PersonaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Network Engineer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0E2A46).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AppTheme.accent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: AppTheme.accent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                filled: false,
                hintText: 'Ask anything…',
                hintStyle:
                    TextStyle(color: Color(0xFF95AEC7), fontSize: 14),
              ),
            ),
          ),
          const Icon(Icons.search, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}
