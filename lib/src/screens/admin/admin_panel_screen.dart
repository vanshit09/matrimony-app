import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final my = profiles.allProfiles.firstWhere(
      (p) => p.uid == auth.currentUser?.uid,
      orElse: () => UserProfile(
        uid: auth.currentUser?.uid ?? '',
        profileId: auth.currentUser?.uid ?? '',
        name: '',
        photoUrl: '',
        role: 'user',
        age: 0,
        gender: '',
        bio: '',
        occupation: '',
        location: '',
        income: '',
        likes: const [],
        likedBy: const [],
        matches: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final isAdmin = my.role == 'admin';
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: isAdmin
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Total Users: ${profiles.allProfiles.length}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: profiles.allProfiles.length,
                    itemBuilder: (context, index) {
                      final u = profiles.allProfiles[index];
                      return ListTile(
                        title: Text(u.name.isNotEmpty ? u.name : u.uid),
                        subtitle: Text(
                            'Age: ${u.age} | ${u.gender} | Role: ${u.role}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile_detail',
                              arguments: u);
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(child: Text('You are not an admin')),
    );
  }
}
