import 'package:flutter/material.dart';
import '../theme.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.selectedIndex, required this.onTap});

  static const List<_NavItemData> _items = [
    _NavItemData(Icons.flag_outlined,           Icons.flag,           'Goals'),
    _NavItemData(Icons.person_search_outlined,  Icons.person_search,  'For You'),
    _NavItemData(Icons.videocam_outlined,       Icons.videocam,       'Webex'),
    _NavItemData(Icons.place_outlined,          Icons.place,          'Nearby'),
    _NavItemData(Icons.sticky_note_2_outlined,  Icons.sticky_note_2,  'Notes'),
    _NavItemData(Icons.notifications_outlined,  Icons.notifications,  'Alerts'),
    _NavItemData(Icons.insights_outlined,       Icons.insights,       'Insights'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.softShadow(blur: 24, y: 10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (i) {
                final it = _items[i];
                final selected = i == selectedIndex;
                return Expanded(
                  child: _NavItem(
                    data: it,
                    selected: selected,
                    compact: compact,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  const _NavItemData(this.iconOutlined, this.iconFilled, this.label);
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _NavItemData data;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : const Color(0xFF94A3B8);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 22 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(selected ? data.iconFilled : data.iconOutlined,
                  size: 22, color: color),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
