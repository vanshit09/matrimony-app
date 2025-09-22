import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.watch<ProfileProvider>();
    final myUid = auth.currentUser?.uid;
    
    // Show all other users except current user
    final List<UserProfile> list = profiles.allProfiles
        .where((u) => u.uid != myUid)
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
      body: list.isEmpty
          ? const Center(
              child: Text('No profiles available yet'),
            )
          : list.isEmpty
              ? const Center(child: Text('No profiles to show'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final user = list[index];
                    if (auth.currentUser?.uid == user.uid) {
                      return const SizedBox.shrink();
                    }
                    final bool isLiked =
                        profiles.myProfile?.likes.contains(user.uid) == true;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoUrl.isEmpty
                            ? null
                            : (user.photoUrl.startsWith('/')
                                ? Image.file(
                                    File(user.photoUrl),
                                  ).image
                                : CachedNetworkImageProvider(user.photoUrl)),
                        child: user.photoUrl.isEmpty
                            ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                          '${user.age}, ${user.gender} • ${user.location} • ${user.occupation}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () async {
                              final myUid = auth.currentUser!.uid;
                              if (isLiked) {
                                await context
                                    .read<ProfileProvider>()
                                    .unlike(myUid, user.uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Removed like for ${user.name}')),
                                  );
                                }
                              } else {
                                await context
                                    .read<ProfileProvider>()
                                    .like(myUid, user.uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Liked ${user.name}')),
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
                    );
                  },
                ),
    );
  }
}
