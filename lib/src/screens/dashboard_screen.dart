import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/romantic_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.watch<ProfileProvider>();
    final myUid = auth.currentUser?.uid;
    
    // Load my profile; if not available, show loader
    final me = profiles.myProfile;
    if (profiles.loading || me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter: show only users whose gender matches my preference
    final List<UserProfile> list = profiles.allProfiles
        .where((u) => u.uid != myUid)
        .where((u) => u.gender == me.preference)
        .toList();

    if (profiles.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Matches'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/activity'),
            icon: const Icon(Icons.history),
            tooltip: 'Activity History',
          ),
        ],
      ),
      body: RomanticBackground(
        child: list.isEmpty
            ? const Center(
                child: Text('No profiles to show'),
              )
            : ListView.builder(
                key: const PageStorageKey('dashboard_list'),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final user = list[index];
                  final bool isLiked =
                      profiles.myProfile?.likes.contains(user.uid) == true;
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? (user.photoUrl.startsWith('/')
                                  ? (File(user.photoUrl).existsSync()
                                      ? FileImage(File(user.photoUrl))
                                      : null)
                                  : (Uri.tryParse(user.photoUrl)?.hasScheme == true
                                      ? CachedNetworkImageProvider(user.photoUrl)
                                      : null))
                              : null,
                          child: user.photoUrl.isEmpty
                              ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                              : null,
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                          '${user.age}, ${user.gender} • ${user.location} • ${user.occupation}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.pink : null,
                            ),
                            onPressed: () async {
                              final myUid = auth.currentUser!.uid;
                              bool ok = false;
                              if (isLiked) {
                                ok = await context
                                    .read<ProfileProvider>()
                                    .unlike(myUid, user.uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(ok
                                            ? 'Removed like for ${user.name}'
                                            : 'Failed to unlike ${user.name}')),
                                  );
                                }
                              } else {
                                ok = await context
                                    .read<ProfileProvider>()
                                    .like(myUid, user.uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(ok
                                            ? 'Liked ${user.name}'
                                            : 'Failed to like ${user.name}')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile_detail',
                                  arguments: user);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/profile_detail',
                            arguments: user);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
