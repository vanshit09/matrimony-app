import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  Future<void> createUserProfile(UserProfile profile) async {
    await users.doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  Stream<List<UserProfile>> streamAllProfiles() {
    return users.snapshots().map(
        (snap) => snap.docs.map((d) => UserProfile.fromMap(d.data())).toList());
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await users.doc(uid).update(data);
  }

  Future<void> likeUser(
      {required String fromUid, required String toUid}) async {
    return _db.runTransaction((tx) async {
      final fromRef = users.doc(fromUid);
      final fromSnap = await tx.get(fromRef);
      if (!fromSnap.exists) return;
      final fromLikes =
          List<String>.from((fromSnap.data()!['likes'] ?? []) as List);
      if (!fromLikes.contains(toUid)) fromLikes.add(toUid);
      tx.update(fromRef,
          {'likes': fromLikes, 'updatedAt': DateTime.now().toIso8601String()});
    });
  }

  Future<void> removeLike(
      {required String fromUid, required String toUid}) async {
    return _db.runTransaction((tx) async {
      final fromRef = users.doc(fromUid);
      final fromSnap = await tx.get(fromRef);
      if (!fromSnap.exists) return;
      final fromLikes =
          List<String>.from((fromSnap.data()!['likes'] ?? []) as List);
      fromLikes.remove(toUid);
      tx.update(fromRef,
          {'likes': fromLikes, 'updatedAt': DateTime.now().toIso8601String()});
    });
  }

  Future<bool> checkMutualMatch(String uidA, String uidB) async {
    final a = await users.doc(uidA).get();
    final b = await users.doc(uidB).get();
    if (!a.exists || !b.exists) return false;
    final aLikes = List<String>.from((a.data()!['likes'] ?? []) as List);
    final bLikes = List<String>.from((b.data()!['likes'] ?? []) as List);
    return aLikes.contains(uidB) && bLikes.contains(uidA);
  }

  Future<void> logActivity(String uid, String message) async {
    // Store ISO timestamps to avoid composite index needs; we'll sort client-side
    await _db.collection('activities').add({
      'uid': uid,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamActivities(String uid) {
    // Avoid requiring a Firestore composite index by not ordering on the server
    // We'll sort client-side using the ISO timestamp string
    return _db
        .collection('activities')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}
