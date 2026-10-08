import 'package:flutter/material.dart';

class CeylonaBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const CeylonaBottomNavigation({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 18),
              selectedIcon: Icon(Icons.home, size: 18),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.search, size: 18), label: 'Search'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_border, size: 18),
              selectedIcon: Icon(Icons.bookmark, size: 18),
              label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.notifications_none, size: 18),
              selectedIcon: Icon(Icons.notifications, size: 18),
              label: 'Alerts'),
          NavigationDestination(
              icon: Icon(Icons.person_outline, size: 18),
              selectedIcon: Icon(Icons.person, size: 18),
              label: 'Profile'),
        ],
      );
}
