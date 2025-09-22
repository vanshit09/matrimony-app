import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
// ... existing code ...

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _occupation = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _income = TextEditingController();
  String _gender = 'Male';
  bool _saving = false;
  File? _localPhotoFile;

  Future<void> _pickLocalPhoto() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String photosDirPath = '${appDir.path}/profile_photos';
    final Directory photosDir = Directory(photosDirPath);
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File saved = await File(picked.path).copy('$photosDirPath/$fileName');
    _localPhotoFile = saved;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profiles = context.read<ProfileProvider>();
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      profiles.loadMyProfile(uid).then((_) {
        final p = profiles.myProfile;
        if (p != null) {
          _name.text = p.name;
          _age.text = p.age.toString();
          _bio.text = p.bio;
          _gender = p.gender;
          _occupation.text = p.occupation;
          _location.text = p.location;
          _income.text = p.income;
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;
    final profiles = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: _localPhotoFile != null
                        ? FileImage(_localPhotoFile!)
                        : (profiles.myProfile?.photoUrl.isNotEmpty == true &&
                                profiles.myProfile!.photoUrl.startsWith('/'))
                            ? FileImage(File(profiles.myProfile!.photoUrl))
                            : null,
                    child: (_localPhotoFile == null &&
                            (profiles.myProfile?.photoUrl.isEmpty ?? true))
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickLocalPhoto,
                    icon: const Icon(Icons.photo),
                    label: const Text('Choose Photo'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: _bio,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3),
              const SizedBox(height: 12),
              TextField(
                  controller: _occupation,
                  decoration: const InputDecoration(labelText: 'Occupation')),
              const SizedBox(height: 12),
              TextField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 12),
              TextField(
                  controller: _income,
                  decoration:
                      const InputDecoration(labelText: 'Annual Income')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (uid == null || _saving)
                      ? null
                      : () async {
                          _saving = true;
                          setState(() {});
                          String photoUrl = profiles.myProfile?.photoUrl ?? '';
                          if (_localPhotoFile != null) {
                            photoUrl = _localPhotoFile!.path;
                          }
                          final profile = UserProfile(
                            uid: uid,
                            profileId: uid,
                            name: _name.text.trim(),
                            photoUrl: photoUrl,
                            role: 'user',
                            age: int.tryParse(_age.text) ?? 18,
                            gender: _gender,
                            bio: _bio.text.trim(),
                            occupation: _occupation.text.trim(),
                            location: _location.text.trim(),
                            income: _income.text.trim(),
                            likes: profiles.myProfile?.likes ?? const [],
                            likedBy: profiles.myProfile?.likedBy ?? const [],
                            matches: profiles.myProfile?.matches ?? const [],
                            createdAt:
                                profiles.myProfile?.createdAt ?? DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          try {
                            await context
                                .read<ProfileProvider>()
                                .createOrUpdateProfile(profile);
                            _saving = false;
                            if (mounted) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Profile saved successfully!')),
                              );
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);
                            }
                          } catch (e) {
                            _saving = false;
                            if (mounted) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error saving profile: $e')),
                              );
                            }
                          }
                        },
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
