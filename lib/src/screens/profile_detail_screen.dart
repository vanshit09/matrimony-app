import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_profile.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/romantic_background.dart';

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
    // Prefer myProfile (updated optimistically) to reflect like/unlike instantly
    UserProfile? currentUserProfile;
    final myUid = auth.currentUser?.uid;
    if (profiles.myProfile != null && profiles.myProfile!.uid == myUid) {
      currentUserProfile = profiles.myProfile;
    } else {
      try {
        currentUserProfile = profiles.allProfiles.firstWhere((p) => p.uid == myUid);
      } catch (_) {
        currentUserProfile = profiles.myProfile;
      }
    }

    if (currentUserProfile == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view profiles')),
      );
    }

    // Initial statuses (used as fallback); UI below uses Consumer to stay reactive
    final initialHasLiked = currentUserProfile.likes.contains(user.uid);
    final initialIsLikedBack = user.likes.contains(currentUserProfile.uid);
    final initialIsMutualMatch = initialHasLiked && initialIsLikedBack;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          if (auth.currentUser?.uid != user.uid)
            Consumer<ProfileProvider>(
              builder: (context, p, _) {
                UserProfile? my = p.myProfile;
                if (my == null) {
                  try {
                    my = p.allProfiles.firstWhere((e) => e.uid == auth.currentUser?.uid);
                  } catch (_) {}
                }
                final liked = my?.likes.contains(user.uid) ?? false;
                return IconButton(
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : null,
                  ),
                  onPressed: () async {
                    if (auth.currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login first')),
                      );
                      return;
                    }
                    final myUid = auth.currentUser!.uid;
                    bool ok;
                    if (liked) {
                      ok = await context.read<ProfileProvider>().unlike(myUid, user.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Removed like for ${user.name}' : 'Failed to unlike ${user.name}')),
                        );
                      }
                    } else {
                      ok = await context.read<ProfileProvider>().like(myUid, user.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Liked ${user.name}' : 'Failed to like ${user.name}')),
                        );
                      }
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: RomanticBackground(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<ProfileProvider>(builder: (context, p, _) {
              UserProfile? my = p.myProfile;
              if (my == null) {
                try {
                  my = p.allProfiles.firstWhere((e) => e.uid == auth.currentUser?.uid);
                } catch (_) {}
              }
              final liked = my?.likes.contains(user.uid) ?? initialHasLiked;
              final isMutual = liked && initialIsLikedBack;
              if (!isMutual) return const SizedBox.shrink();
              return Card(
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
              );
            }),
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
              Consumer<ProfileProvider>(builder: (context, p, _) {
                UserProfile? my = p.myProfile;
                if (my == null) {
                  try {
                    my = p.allProfiles.firstWhere((e) => e.uid == auth.currentUser?.uid);
                  } catch (_) {}
                }
                final liked = my?.likes.contains(user.uid) ?? initialHasLiked;
                final isMutual = liked && initialIsLikedBack;
                return _buildSection(
                  'Match Status',
                  [
                    ListTile(
                      leading: Icon(
                        isMutual
                            ? Icons.favorite
                            : liked
                                ? Icons.favorite
                                : Icons.favorite_border,
                        color: isMutual
                            ? Colors.red
                            : liked
                                ? Colors.orange
                                : Colors.grey,
                      ),
                      title: Text(
                        isMutual
                            ? 'It\'s a Match! 💕'
                            : liked
                                ? 'You liked this profile'
                                : initialIsLikedBack
                                    ? 'This person likes you'
                                    : 'No interaction yet',
                        style: TextStyle(
                          color: isMutual ? Colors.red : null,
                          fontWeight:
                              isMutual ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        isMutual
                            ? 'You can now start chatting!'
                            : 'Like this profile to show your interest',
                      ),
                    ),
                  ],
                );
              }),

            const SizedBox(height: 16),

            // Match Status
            Consumer<ProfileProvider>(builder: (context, p, _) {
              final my = p.myProfile;
              final liked = my?.likes.contains(user.uid) ?? initialHasLiked;
              final isMutual = liked && initialIsLikedBack;
              if (!isMutual) return const SizedBox.shrink();
              return const Card(
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
              );
            }),
          ],
          ),
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
        backgroundImage:
            File(url).existsSync() ? FileImage(File(url)) : null,
        child: File(url).existsSync() ? null : const Icon(Icons.person, size: 40),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage:
          (Uri.tryParse(url)?.hasScheme == true) ? NetworkImage(url) : null,
      child: (Uri.tryParse(url)?.hasScheme == true)
          ? null
          : const Icon(Icons.person, size: 40),
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
