import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  List<UserProfile> allProfiles = [];
  UserProfile? myProfile;
  bool loading = false;
  String? error;

  bool _streamStarted = false;

  ProfileProvider();

  void ensureProfilesStream() {
    if (_streamStarted) return;
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return; // start after login only
    _streamStarted = true;
    _db.streamAllProfiles().listen((list) {
      allProfiles = list;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      notifyListeners();
    });
  }

  Future<void> loadMyProfile(String uid) async {
    loading = true;
    notifyListeners();
    myProfile = await _db.getUserProfile(uid);
    loading = false;
    notifyListeners();
  }

  Future<void> createOrUpdateProfile(UserProfile profile) async {
    try {
      if (await _db.getUserProfile(profile.uid) == null) {
        await _db.createUserProfile(profile);
      } else {
        await _db.updateProfile(profile.uid, profile.toMap());
      }
      // Reload my profile after update
      await loadMyProfile(profile.uid);
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getProfile(String uid) async {
    try {
      return await _db.getUserProfile(uid);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  bool isProfileComplete(UserProfile? p) {
    if (p == null) return false;
    return p.name.isNotEmpty &&
        p.age > 0 &&
        p.gender.isNotEmpty &&
        p.occupation.isNotEmpty &&
        p.location.isNotEmpty &&
        p.income.isNotEmpty;
  }

  Future<bool> like(String fromUid, String toUid) async {
    // Optimistic update for instant UI feedback
    final previousLikes = List<String>.from(myProfile?.likes ?? const []);
    if (myProfile != null && !myProfile!.likes.contains(toUid)) {
      myProfile = UserProfile(
        uid: myProfile!.uid,
        profileId: myProfile!.profileId,
        name: myProfile!.name,
        photoUrl: myProfile!.photoUrl,
        role: myProfile!.role,
        age: myProfile!.age,
        gender: myProfile!.gender,
        preference: myProfile!.preference,
        bio: myProfile!.bio,
        occupation: myProfile!.occupation,
        location: myProfile!.location,
        income: myProfile!.income,
        likes: [...myProfile!.likes, toUid],
        likedBy: myProfile!.likedBy,
        matches: myProfile!.matches,
        createdAt: myProfile!.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
    try {
      await _db.likeUser(fromUid: fromUid, toUid: toUid);
    } catch (e) {
      // Revert on failure
      myProfile = myProfile == null
          ? null
          : UserProfile(
              uid: myProfile!.uid,
              profileId: myProfile!.profileId,
              name: myProfile!.name,
              photoUrl: myProfile!.photoUrl,
              role: myProfile!.role,
              age: myProfile!.age,
              gender: myProfile!.gender,
              preference: myProfile!.preference,
              bio: myProfile!.bio,
              occupation: myProfile!.occupation,
              location: myProfile!.location,
              income: myProfile!.income,
              likes: previousLikes,
              likedBy: myProfile!.likedBy,
              matches: myProfile!.matches,
              createdAt: myProfile!.createdAt,
              updatedAt: myProfile!.updatedAt,
            );
      notifyListeners();
      rethrow;
    }
    // Log like activity only for the actor (do not notify the other user here)
    try {
      final other = await _db.getUserProfile(toUid);
      final otherName = other?.name ?? toUid;
      await _db.logActivity(fromUid, 'You liked $otherName');
    } catch (_) {}
    final isMatch = await _db.checkMutualMatch(fromUid, toUid);
    if (isMatch) {
      final me = await _db.getUserProfile(fromUid);
      final other = await _db.getUserProfile(toUid);
      final meName = me?.name ?? fromUid;
      final otherName = other?.name ?? toUid;
      await _db.logActivity(fromUid, 'You matched with $otherName');
      await _db.logActivity(toUid, 'You matched with $meName');
    }
    return true;
  }

  Future<bool> unlike(String fromUid, String toUid) async {
    // Optimistic update for instant UI feedback
    final previousLikes = List<String>.from(myProfile?.likes ?? const []);
    if (myProfile != null && myProfile!.likes.contains(toUid)) {
      final updated = List<String>.from(myProfile!.likes)..remove(toUid);
      myProfile = UserProfile(
        uid: myProfile!.uid,
        profileId: myProfile!.profileId,
        name: myProfile!.name,
        photoUrl: myProfile!.photoUrl,
        role: myProfile!.role,
        age: myProfile!.age,
        gender: myProfile!.gender,
        preference: myProfile!.preference,
        bio: myProfile!.bio,
        occupation: myProfile!.occupation,
        location: myProfile!.location,
        income: myProfile!.income,
        likes: updated,
        likedBy: myProfile!.likedBy,
        matches: myProfile!.matches,
        createdAt: myProfile!.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
    try {
      await _db.removeLike(fromUid: fromUid, toUid: toUid);
    } catch (e) {
      // Revert on failure
      myProfile = myProfile == null
          ? null
          : UserProfile(
              uid: myProfile!.uid,
              profileId: myProfile!.profileId,
              name: myProfile!.name,
              photoUrl: myProfile!.photoUrl,
              role: myProfile!.role,
              age: myProfile!.age,
              gender: myProfile!.gender,
              preference: myProfile!.preference,
              bio: myProfile!.bio,
              occupation: myProfile!.occupation,
              location: myProfile!.location,
              income: myProfile!.income,
              likes: previousLikes,
              likedBy: myProfile!.likedBy,
              matches: myProfile!.matches,
              createdAt: myProfile!.createdAt,
              updatedAt: myProfile!.updatedAt,
            );
      notifyListeners();
      rethrow;
    }
    // Log unlike activity only for the actor
    try {
      final other = await _db.getUserProfile(toUid);
      final otherName = other?.name ?? toUid;
      await _db.logActivity(fromUid, 'You unliked $otherName');
    } catch (_) {}
    return true;
  }
}
