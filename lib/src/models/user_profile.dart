class UserProfile {
  final String uid;
  final String profileId; // unique profile id
  final String name;
  final String photoUrl;
  final String role; // user or admin
  final int age;
  final String gender;
  final String bio;
  final String occupation;
  final String location;
  final String income;
  final List<String> likes; // uids liked by this user
  final List<String> likedBy; // uids who liked this user
  final List<String> matches; // uids of matched users
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.profileId,
    required this.name,
    required this.photoUrl,
    required this.role,
    required this.age,
    required this.gender,
    required this.bio,
    required this.occupation,
    required this.location,
    required this.income,
    required this.likes,
    required this.likedBy,
    required this.matches,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      profileId: map['profileId'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'user',
      age: (map['age'] ?? 0) as int,
      gender: map['gender'] ?? '',
      bio: map['bio'] ?? '',
      occupation: map['occupation'] ?? '',
      location: map['location'] ?? '',
      income: map['income'] ?? '',
      likes: List<String>.from((map['likes'] ?? []) as List),
      likedBy: List<String>.from((map['likedBy'] ?? []) as List),
      matches: List<String>.from((map['matches'] ?? []) as List),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'profileId': profileId,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'age': age,
      'gender': gender,
      'bio': bio,
      'occupation': occupation,
      'location': location,
      'income': income,
      'likes': likes,
      'likedBy': likedBy,
      'matches': matches,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
