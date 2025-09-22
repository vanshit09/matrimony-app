class Match {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime matchedAt;
  final bool isActive;
  final String? lastMessageId;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount; // userId -> unread message count

  Match({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.matchedAt,
    this.isActive = true,
    this.lastMessageId,
    this.lastMessageAt,
    this.unreadCount = const {},
  });

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] ?? '',
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      matchedAt: DateTime.tryParse(map['matchedAt'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      lastMessageId: map['lastMessageId'],
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt'])
          : null,
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'matchedAt': matchedAt.toIso8601String(),
      'isActive': isActive,
      'lastMessageId': lastMessageId,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  Match copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? matchedAt,
    bool? isActive,
    String? lastMessageId,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
  }) {
    return Match(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      matchedAt: matchedAt ?? this.matchedAt,
      isActive: isActive ?? this.isActive,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  // Get the other user's ID in this match
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}
