import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/organizer_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/admin_portal_screen.dart';
import 'services/db.dart';
import 'services/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) await NotificationsService.instance.initialize();
  runApp(const CeylonaApp());
}

class CeylonaApp extends StatelessWidget {
  const CeylonaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ceylona',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC107)),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (c, s) {
            if (s.data == null) return const LoginScreen();
            return FutureBuilder(
              future: Db.appAccess(),
              builder: (context, profile) {
                if (!profile.hasData) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                final access = profile.data!;
                final data = access['profile'] as Map<String, dynamic>;
                if (access['isAdmin'] == true) return const AdminPortalScreen();
                return MainNav(
                  isOrganizer: data['isOrganizer'] == true,
                  isAdmin: access['isAdmin'] == true,
                );
              },
            );
          },
        ),
      );
}

class MainNav extends StatefulWidget {
  final bool isOrganizer;
  final bool isAdmin;
  const MainNav({super.key, required this.isOrganizer, required this.isAdmin});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int i = 0;
  late bool organizerEnabled = widget.isOrganizer;
  late bool adminEnabled = widget.isAdmin;
  bool organizerMode = false;
  @override
  Widget build(BuildContext context) {
    final pages = organizerMode
        ? <Widget>[
            const OrganizerScreen(),
            const OrganizerScreen(view: OrganizerView.events),
            const OrganizerScreen(view: OrganizerView.create),
            const AnalyticsScreen(),
            ProfileScreen(
              isOrganizer: organizerEnabled,
              organizerMode: true,
              onModeChanged: (mode) => setState(() {
                organizerMode = mode;
                i = 0;
              }),
            ),
          ]
        : <Widget>[
            const HomeScreen(),
            const SearchScreen(),
            const SavedScreen(),
            const NotificationsScreen(),
            ProfileScreen(
              isOrganizer: organizerEnabled,
              organizerMode: false,
              onOrganizerEnabled: () => setState(() => organizerEnabled = true),
              onModeChanged: (mode) => setState(() {
                organizerMode = mode;
                i = 0;
              }),
            ),
          ];
    if (i >= pages.length) i = 0;
    final destinations = organizerMode
        ? const <NavigationDestination>[
            NavigationDestination(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.event_note), label: 'Events'),
            NavigationDestination(
                icon: Icon(Icons.add_circle), label: 'Create'),
            NavigationDestination(
                icon: Icon(Icons.analytics), label: 'Analytics'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ]
        : const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.bookmark), label: 'Saved'),
            NavigationDestination(
                icon: Icon(Icons.notifications), label: 'Alerts'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ];
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: destinations,
      ),
    );
  }
}
