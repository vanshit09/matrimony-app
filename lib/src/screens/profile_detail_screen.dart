import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_profile.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final auth = context.watch<AuthProvider>();
    final profiles = context.watch<ProfileProvider>();

    // Handle no arguments case
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No profile to show')),
      );
    }

    // Get the user profile
    UserProfile user;

    if (args is UserProfile) {
      // Try to get fresh data from provider first
      try {
        user = profiles.allProfiles.firstWhere((p) => p.uid == args.uid);
      } catch (_) {
        // If not found in provider, use the passed profile
        user = args;
      }
    } else if (args is String) {
      // If we got a uid, look up the profile
      try {
        user = profiles.allProfiles.firstWhere((p) => p.uid == args);
      } catch (_) {
        // Profile not found in provider
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: const Center(child: Text('Profile not found')),
        );
      }
    } else {
      // Invalid argument type
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Invalid profile data')),
      );
    }

    // Get current user profile
    UserProfile? currentUserProfile;
    try {
      currentUserProfile = profiles.allProfiles
          .firstWhere((p) => p.uid == auth.currentUser?.uid);
    } catch (_) {
      currentUserProfile = profiles.myProfile;
    }

    if (currentUserProfile == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view profiles')),
      );
    }

    // Check mutual like status
    final hasLiked = currentUserProfile.likes.contains(user.uid);
    final isLikedBack = user.likes.contains(currentUserProfile.uid);
    final isMutualMatch = hasLiked && isLikedBack;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          if (auth.currentUser?.uid != user.uid)
            IconButton(
              icon: Icon(
                hasLiked ? Icons.favorite : Icons.favorite_border,
                color: hasLiked ? Colors.red : null,
              ),
              onPressed: () async {
                if (auth.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login first')),
                  );
                  return;
                }

                final myUid = auth.currentUser!.uid;
                if (hasLiked) {
                  await context.read<ProfileProvider>().unlike(myUid, user.uid);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed like for ${user.name}')),
                    );
                  }
                } else {
                  await context.read<ProfileProvider>().like(myUid, user.uid);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Liked ${user.name}')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMutualMatch)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'It\'s a Match!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Profile Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildProfileAvatar(context, user)),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '${user.age} years • ${user.gender}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location & Work
            _buildSection(
              'Location & Work',
              [
                _buildInfoRow('Location', user.location),
                _buildInfoRow('Occupation', user.occupation),
                _buildInfoRow('Income', user.income),
              ],
            ),

            // About Section
            if (user.bio.isNotEmpty)
              _buildSection(
                'About Me',
                [
                  Text(
                    user.bio,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

            // Match Status
            if (auth.currentUser?.uid != user.uid)
              _buildSection(
                'Match Status',
                [
                  ListTile(
                    leading: Icon(
                      isMutualMatch
                          ? Icons.favorite
                          : hasLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                      color: isMutualMatch
                          ? Colors.red
                          : hasLiked
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    title: Text(
                      isMutualMatch
                          ? 'It\'s a Match! 💕'
                          : hasLiked
                              ? 'You liked this profile'
                              : isLikedBack
                                  ? 'This person likes you'
                                  : 'No interaction yet',
                      style: TextStyle(
                        color: isMutualMatch ? Colors.red : null,
                        fontWeight:
                            isMutualMatch ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      isMutualMatch
                          ? 'You can now start chatting!'
                          : 'Like this profile to show your interest',
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Match Status
            if (isMutualMatch)
              const Card(
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'It\'s a Match!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, UserProfile user) {
    final String url = user.photoUrl;
    if (url.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (url.startsWith('/')) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(url)),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(url),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
