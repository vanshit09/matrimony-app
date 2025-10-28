import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/romantic_background.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.watch<ProfileProvider>();
    UserProfile? me;
    try {
      me = profiles.allProfiles
          .firstWhere((p) => p.uid == auth.currentUser?.uid);
    } catch (_) {
      me = profiles.myProfile;
    }
    if (auth.currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final avatarImage = me.photoUrl.isEmpty
        ? null
        : (me.photoUrl.startsWith('/')
            ? Image.file(File(me.photoUrl)).image
            : NetworkImage(me.photoUrl));

    return Scaffold(
      body: RomanticBackground(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Text(me.name.isNotEmpty ? me.name[0] : '?')
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: ${me.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Age: ${me.age}'),
            const SizedBox(height: 8),
            Text('Gender: ${me.gender}'),
            const SizedBox(height: 8),
            Text('Occupation: ${me.occupation}'),
            const SizedBox(height: 8),
            Text('Location: ${me.location}'),
            const SizedBox(height: 8),
            Text('Income: ${me.income}'),
            const SizedBox(height: 16),
            const Text('Bio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(me.bio.isEmpty ? 'No bio' : me.bio),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile_edit');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
