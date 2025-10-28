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
  String _preference = 'Female';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profiles = context.read<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0E6), Color(0xFFF3E7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Join Matrimony',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text('Create your profile to find the right match'),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _age,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _occupation,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _location,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _income,
                        decoration: const InputDecoration(
                          labelText: 'Annual Income',
                          prefixIcon: Icon(Icons.currency_rupee_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _preference,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('See only Male')),
                          DropdownMenuItem(value: 'Female', child: Text('See only Female')),
                        ],
                        onChanged: (v) => setState(() => _preference = v ?? 'Female'),
                        decoration: const InputDecoration(
                          labelText: 'Preference',
                          prefixIcon: Icon(Icons.favorite_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                        content: Text('Password must be at least 6 characters'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    final ok = await auth.register(
                                        _email.text.trim(), _password.text);
                                    if (!mounted) return;

                                    if (ok && auth.currentUser != null) {
                                      final profile = UserProfile(
                                        uid: auth.currentUser!.uid,
                                        profileId: auth.currentUser!.uid,
                                        name: _name.text.trim(),
                                        photoUrl: '',
                                        role: 'user',
                                        age: int.tryParse(_age.text) ?? 18,
                                        gender: _gender,
                                        preference: _preference,
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

                                      await profiles.createOrUpdateProfile(profile);

                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account created successfully! Please login.'),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      await Future.delayed(const Duration(seconds: 2));
                                      if (!mounted) return;
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
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
