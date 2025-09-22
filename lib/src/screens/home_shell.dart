import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'admin/admin_panel_screen.dart';
import 'likings_screen.dart';
import 'matching_screen.dart';
import 'dashboard_screen.dart';
import 'my_profile_screen.dart';
import 'matches_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Ensure myProfile is loaded once we have an authenticated user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final profiles = context.read<ProfileProvider>();
      final uid = auth.currentUser?.uid;
      if (uid != null && profiles.myProfile == null) {
        profiles.loadMyProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileProvider>();
    final isAdmin = (profiles.myProfile?.role == 'admin') ||
        (profiles.allProfiles.any((p) =>
            p.uid == context.read<AuthProvider>().currentUser?.uid &&
            p.role == 'admin'));

    // Check if profile needs to be completed
    if (!profiles.loading && !profiles.isProfileComplete(profiles.myProfile)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complete Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please complete your profile to continue',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/profile_edit'),
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        ),
      );
    }

    final tabs = <Widget>[
      const DashboardScreen(),
      const LikingsScreen(),
      const MatchingScreen(),
      const MatchesScreen(),
      const MyProfileScreen(),
      if (isAdmin) const AdminPanelScreen(),
    ];

    return Scaffold(
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(
              icon: Icon(Icons.favorite), label: 'Likings'),
          const NavigationDestination(
              icon: Icon(Icons.favorite_outlined), label: 'Matching'),
          const NavigationDestination(icon: Icon(Icons.chat), label: 'Matches'),
          const NavigationDestination(
              icon: Icon(Icons.person), label: 'Profile'),
          if (isAdmin)
            const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
      appBar: AppBar(
        title: const Text('Matrimony'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
    );
  }
}
