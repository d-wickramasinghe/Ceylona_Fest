// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/saved_screen.dart';
// import 'screens/organizer_screen.dart';
// import 'screens/profile_screen.dart';
// import 'screens/search_screen.dart';
// import 'screens/notifications_screen.dart';
// import 'screens/analytics_screen.dart';
// import 'screens/admin_portal_screen.dart';
// import 'services/db.dart';
// import 'services/notifications.dart';
// import 'theme/app_theme.dart';
// import 'widgets/ceylona_bottom_navigation.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   if (!kIsWeb) await NotificationsService.instance.initialize();
//   runApp(const CeylonaApp());
// }

// class CeylonaApp extends StatelessWidget {
//   const CeylonaApp({super.key});
//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         title: 'Ceylona',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.light,
//         home: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.userChanges(),
//           builder: (c, s) {
//             if (s.data == null) return const LoginScreen();
//             return FutureBuilder(
//               future: Db.appAccess(),
//               builder: (context, profile) {
//                 if (!profile.hasData) {
//                   return const Scaffold(
//                       body: Center(child: CircularProgressIndicator()));
//                 }
//                 final access = profile.data!;
//                 final data = access['profile'] as Map<String, dynamic>;
//                 if (access['isAdmin'] == true) return const AdminPortalScreen();
//                 return MainNav(
//                   isOrganizer: data['isOrganizer'] == true,
//                   isAdmin: access['isAdmin'] == true,
//                 );
//               },
//             );
//           },
//         ),
//       );
// }

// class MainNav extends StatefulWidget {
//   final bool isOrganizer;
//   final bool isAdmin;
//   const MainNav({super.key, required this.isOrganizer, required this.isAdmin});
//   @override
//   State<MainNav> createState() => _MainNavState();
// }

// class _MainNavState extends State<MainNav> {
//   int i = 0;
//   late bool organizerEnabled = widget.isOrganizer;
//   late bool adminEnabled = widget.isAdmin;
//   bool organizerMode = false;

//   @override
//   void initState() {
//     super.initState();
//     seekerNavigationIndex.addListener(_handleSeekerNavigation);
//   }

//   @override
//   void dispose() {
//     seekerNavigationIndex.removeListener(_handleSeekerNavigation);
//     super.dispose();
//   }

//   void _handleSeekerNavigation() {
//     if (!organizerMode && mounted) {
//       setState(() => i = seekerNavigationIndex.value);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = organizerMode
//         ? <Widget>[
//             const OrganizerScreen(),
//             const OrganizerScreen(view: OrganizerView.events),
//             const OrganizerScreen(view: OrganizerView.create),
//             const AnalyticsScreen(),
//             ProfileScreen(
//               isOrganizer: organizerEnabled,
//               organizerMode: true,
//               onModeChanged: (mode) {
//                 setState(() {
//                   organizerMode = mode;
//                   i = 0;
//                 });
//                 seekerNavigationIndex.value = 0;
//               },
//             ),
//           ]
//         : <Widget>[
//             const HomeScreen(),
//             const SearchScreen(),
//             const SavedScreen(),
//             const NotificationsScreen(),
//             ProfileScreen(
//               isOrganizer: organizerEnabled,
//               organizerMode: false,
//               onOrganizerEnabled: () => setState(() => organizerEnabled = true),
//               onModeChanged: (mode) {
//                 setState(() {
//                   organizerMode = mode;
//                   i = 0;
//                 });
//                 seekerNavigationIndex.value = 0;
//               },
//             ),
//           ];
//     if (i >= pages.length) i = 0;
//     final destinations = organizerMode
//         ? const <NavigationDestination>[
//             NavigationDestination(
//                 icon: Icon(Icons.dashboard), label: 'Dashboard'),
//             NavigationDestination(
//                 icon: Icon(Icons.event_note), label: 'Events'),
//             NavigationDestination(
//                 icon: Icon(Icons.add_circle), label: 'Create'),
//             NavigationDestination(
//                 icon: Icon(Icons.analytics), label: 'Analytics'),
//             NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
//           ]
//         : const <NavigationDestination>[
//             NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
//             NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
//             NavigationDestination(icon: Icon(Icons.bookmark), label: 'Saved'),
//             NavigationDestination(
//                 icon: Icon(Icons.notifications), label: 'Alerts'),
//             NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
//           ];
//     return Scaffold(
//       body: pages[i],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: i,
//         onDestinationSelected: (v) {
//           if (organizerMode) {
//             setState(() => i = v);
//           } else {
//             seekerNavigationIndex.value = v;
//           }
//         },
//         destinations: destinations,
//       ),
//     );
//   }
// }



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
import 'theme/app_theme.dart';
import 'widgets/ceylona_bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) await NotificationsService.instance.initialize();
  runApp(const CeylonaApp());
}

// Listens only to sign-in / sign-out state, rather than rebuilding the
// entire navigation tree on profile updates and token refreshes.
class CeylonaApp extends StatefulWidget {
  const CeylonaApp({super.key});

  @override
  State<CeylonaApp> createState() => _CeylonaAppState();
}

class _CeylonaAppState extends State<CeylonaApp> {
  late final Stream<User?> _authStream =
      FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ceylona',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: StreamBuilder<User?>(
          stream: _authStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _StartupLoadingScreen();
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Authentication failed: ${snapshot.error}'),
                ),
              );
            }
            final user = snapshot.data;
            if (user == null) return const LoginScreen();

            // Creates a new access-loader only when a DIFFERENT account signs in.
            return _AppAccessScreen(
              key: ValueKey(user.uid),
            );
          },
        ),
      );
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class _AppAccessScreen extends StatefulWidget {
  const _AppAccessScreen({super.key});

  @override
  State<_AppAccessScreen> createState() => _AppAccessScreenState();
}

class _AppAccessScreenState extends State<_AppAccessScreen> {
  late final Future<Map<String, dynamic>> _accessFuture;

  @override
  void initState() {
    super.initState();
    // Do not start a new profile-access request on every rebuild.
    _accessFuture = Db.appAccess();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
        future: _accessFuture,
        builder: (context, profile) {
          if (profile.connectionState != ConnectionState.done) {
            return const _StartupLoadingScreen();
          }
          if (profile.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Could not load profile: ${profile.error}'),
              ),
            );
          }
          if (!profile.hasData) return const _StartupLoadingScreen();

          final access = profile.data!;
          final data =
              (access['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{};

          if (access['isAdmin'] == true) return const AdminPortalScreen();

          return MainNav(
            isOrganizer: data['isOrganizer'] == true,
            isAdmin: access['isAdmin'] == true,
          );
        },
      );
}

// The application's existing seeker/organizer navigation is unchanged.
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
  void initState() {
    super.initState();
    seekerNavigationIndex.addListener(_handleSeekerNavigation);
  }

  @override
  void dispose() {
    seekerNavigationIndex.removeListener(_handleSeekerNavigation);
    super.dispose();
  }

  void _handleSeekerNavigation() {
    if (!organizerMode && mounted) {
      setState(() => i = seekerNavigationIndex.value);
    }
  }

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
              onModeChanged: (mode) {
                setState(() {
                  organizerMode = mode;
                  i = 0;
                });
                seekerNavigationIndex.value = 0;
              },
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
              onModeChanged: (mode) {
                setState(() {
                  organizerMode = mode;
                  i = 0;
                });
                seekerNavigationIndex.value = 0;
              },
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
        onDestinationSelected: (v) {
          if (organizerMode) {
            setState(() => i = v);
          } else {
            seekerNavigationIndex.value = v;
          }
        },
        destinations: destinations,
      ),
    );
  }
}