import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder(
              stream: FirestoreService().streamActivities(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final list = (snapshot.data ?? [])
                  ..sort((a, b) => (b['createdAt'] ?? '')
                      .toString()
                      .compareTo((a['createdAt'] ?? '').toString()));
                if (list.isEmpty) {
                  return const Center(child: Text('No activity'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final a = list[index];
                    final when = a['createdAt']?.toString() ?? '';
                    return ListTile(
                      title: Text(a['message'] ?? ''),
                      subtitle: Text(when),
                    );
                  },
                );
              },
            ),
    );
  }
}
