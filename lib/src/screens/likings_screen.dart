import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/romantic_background.dart';

class LikingsScreen extends StatelessWidget {
  const LikingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.watch<ProfileProvider>();
    final myUid = auth.currentUser?.uid;
    if (myUid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    var me = profiles.myProfile;
    try {
      me = profiles.allProfiles.firstWhere((p) => p.uid == myUid);
    } catch (_) {}
    final likes = me?.likes ?? const <String>[];
    final likedUsers =
        profiles.allProfiles.where((u) => likes.contains(u.uid)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Likings')),
      body: RomanticBackground(
        child: likedUsers.isEmpty
            ? const Center(child: Text('No likings yet'))
            : ListView.builder(
                itemCount: likedUsers.length,
                itemBuilder: (context, index) {
                  final user = likedUsers[index];
                  final ImageProvider<Object>? imageProvider = user.photoUrl.isNotEmpty
                      ? (user.photoUrl.startsWith('/')
                          ? (File(user.photoUrl).existsSync()
                              ? (FileImage(File(user.photoUrl))
                                  as ImageProvider<Object>)
                              : null)
                          : (Uri.tryParse(user.photoUrl)?.hasScheme == true
                              ? (CachedNetworkImageProvider(user.photoUrl)
                                  as ImageProvider<Object>)
                              : null))
                      : null;
                  final bool isLiked = (me?.likes.contains(user.uid) ?? false);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                            : null,
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${user.age}, ${user.gender}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          if (!isLiked) return;
                          await context
                              .read<ProfileProvider>()
                              .unlike(myUid, user.uid);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Removed like for ${user.name}')),
                            );
                          }
                        },
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
