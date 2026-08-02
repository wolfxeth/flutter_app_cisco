import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
        BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'For You'),
        BottomNavigationBarItem(icon: Icon(Icons.video_call), label: 'Webex'),
        BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Nearby'),
        BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
      ],
    );
  }
}
