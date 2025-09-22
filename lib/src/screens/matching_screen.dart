import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/chat_provider.dart';
import '../models/user_profile.dart';

class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.watch<ProfileProvider>();
    final myUid = auth.currentUser?.uid;

    if (myUid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    // Get current user's profile
    UserProfile? myProfile;
    try {
      myProfile = profiles.allProfiles.firstWhere((p) => p.uid == myUid);
    } catch (_) {
      return const Scaffold(body: Center(child: Text('Profile not found')));
    }

    // Get mutual matches (users who like each other)
    final mutualMatches = profiles.allProfiles.where((otherUser) {
      // Skip own profile
      if (otherUser.uid == myUid) return false;

      // Check if both users like each other
      bool iLikeThem = myProfile?.likes.contains(otherUser.uid) ?? false;
      bool theyLikeMe = otherUser.likes.contains(myUid);

      return iLikeThem && theyLikeMe;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual Matches'),
      ),
      body: mutualMatches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No mutual matches yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When you and another user like each other,\nthey will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: mutualMatches.length,
              itemBuilder: (context, index) {
                final user = mutualMatches[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl.isEmpty
                          ? null
                          : (user.photoUrl.startsWith('/')
                              ? Image.file(File(user.photoUrl)).image
                              : CachedNetworkImageProvider(user.photoUrl)),
                      child: user.photoUrl.isEmpty
                          ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                          : null,
                    ),
                    title: Text(user.name),
                    subtitle: Text('${user.age}, ${user.location}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () async {
                            // Check if match already exists
                            final chatProvider = context.read<ChatProvider>();
                            final isMatched = await chatProvider
                                .areUsersMatched(myUid, user.uid);

                            if (!isMatched) {
                              // Create match
                              await chatProvider.createMatch(
                                  myUid, user.uid, context);
                            }

                            // Navigate to chat
                            Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {
                                'otherUserId': user.uid,
                                'otherUserName': user.name,
                                'otherUserPhotoUrl': user.photoUrl,
                              },
                            );
                          },
                          icon: const Icon(Icons.chat,
                              color: Colors.pink, size: 16),
                          label: const Text('Chat',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile_detail',
                        arguments: user,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
