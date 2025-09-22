import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../src/models/user_profile.dart';
import '../../../src/providers/auth_provider.dart';
import '../../../src/providers/profile_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _occupation = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _income = TextEditingController();
  String _gender = 'Male';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.read<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 12),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 12),
              TextField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading
                      ? null
                      : () async {
                          // Basic validation
                          if (_email.text.trim().isEmpty ||
                              _password.text.isEmpty ||
                              _name.text.trim().isEmpty ||
                              _age.text.trim().isEmpty ||
                              _occupation.text.trim().isEmpty ||
                              _location.text.trim().isEmpty ||
                              _income.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Email validation
                          if (!_email.text.trim().contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Password validation
                          if (_password.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Password must be at least 6 characters'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            // Attempt to register
                            final ok = await auth.register(
                                _email.text.trim(), _password.text);
                            if (!mounted) return;

                            if (ok && auth.currentUser != null) {
                              // Create user profile
                              final profile = UserProfile(
                                uid: auth.currentUser!.uid,
                                profileId: auth.currentUser!.uid,
                                name: _name.text.trim(),
                                photoUrl: '',
                                role: 'user',
                                age: int.tryParse(_age.text) ?? 18,
                                gender: _gender,
                                bio: '',
                                occupation: _occupation.text.trim(),
                                location: _location.text.trim(),
                                income: _income.text.trim(),
                                likes: const [],
                                likedBy: const [],
                                matches: const [],
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              // Save profile
                              await profiles.createOrUpdateProfile(profile);

                              if (!mounted) return;

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Account created successfully! Please login.'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // Wait for snackbar to be visible
                              await Future.delayed(const Duration(seconds: 2));

                              if (!mounted) return;

                              // Sign out and redirect to login
                              await auth.signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: auth.loading
                      ? const CircularProgressIndicator()
                      : const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
