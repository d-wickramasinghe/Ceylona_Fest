import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';

class CeylonaBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const CeylonaBottomNavigation({super.key, this.selectedIndex = 0});

    void _navigate(BuildContext context, int index) {
        final page = switch (index) {
            0 => const HomeScreen(),
            1 => const SearchScreen(),
            2 => const SavedScreen(),
            3 => const NotificationsScreen(),
            _ => const ProfileScreen(),
        };
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }

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
          onDestinationSelected: (index) => _navigate(context, index),
      );
}
