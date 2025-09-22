import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_detail_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/likings_screen.dart';
import '../screens/home_shell.dart';
import '../screens/matches_screen.dart';
import '../screens/chat_screen.dart';

class AppRouter {
  static const String initialRoute = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
            builder: (_) => const LoginScreen(), settings: settings);
      case '/register':
        return MaterialPageRoute(
            builder: (_) => const RegisterScreen(), settings: settings);
      case '/dashboard':
        return MaterialPageRoute(
            builder: (_) => const DashboardScreen(), settings: settings);
      case '/home':
        return MaterialPageRoute(
            builder: (_) => const HomeShell(), settings: settings);
      case '/profile_detail':
        return MaterialPageRoute(
            builder: (_) => const ProfileDetailScreen(), settings: settings);
      case '/profile_edit':
        return MaterialPageRoute(
            builder: (_) => const ProfileEditScreen(), settings: settings);
      case '/admin':
        return MaterialPageRoute(
            builder: (_) => const AdminPanelScreen(), settings: settings);
      case '/activity':
        return MaterialPageRoute(
            builder: (_) => const ActivityScreen(), settings: settings);
      case '/likings':
        return MaterialPageRoute(
            builder: (_) => const LikingsScreen(), settings: settings);
      case '/matches':
        return MaterialPageRoute(
            builder: (_) => const MatchesScreen(), settings: settings);
      case '/chat':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ChatScreen(
              otherUserId: args['otherUserId'] ?? '',
              otherUserName: args['otherUserName'] ?? '',
              otherUserPhotoUrl: args['otherUserPhotoUrl'] ?? '',
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
            builder: (_) => const LikingsScreen(), settings: settings);
      default:
        return MaterialPageRoute(
            builder: (_) => const LoginScreen(), settings: settings);
    }
  }
}
