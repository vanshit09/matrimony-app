import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import '../services/chat_service.dart';
import '../services/simple_notification_service.dart';
import 'profile_provider.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Match> _matches = [];
  List<ChatMessage> _currentChatMessages = [];
  Map<String, UserProfile> _matchProfiles = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Match> get matches => _matches;
  List<ChatMessage> get currentChatMessages => _currentChatMessages;
  Map<String, UserProfile> get matchProfiles => _matchProfiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get matches for current user
  Future<void> loadMatches() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Listen to matches stream
      ChatService.getMatches().listen(
        (matches) {
          _matches = matches;
          notifyListeners();
          _loadMatchProfiles();
        },
        onError: (error) {
          _setError('Failed to load matches: $error');
        },
      );
    } catch (e) {
      _setError('Failed to load matches: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load profiles for all matches
  Future<void> _loadMatchProfiles() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      for (final match in _matches) {
        final otherUserId = match.getOtherUserId(currentUser.uid);
        if (!_matchProfiles.containsKey(otherUserId)) {
          try {
            final profile = await ProfileProvider().getProfile(otherUserId);
            if (profile != null) {
              _matchProfiles[otherUserId] = profile;
            }
          } catch (e) {
            debugPrint('Error loading profile for $otherUserId: $e');
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading match profiles: $e');
    }
  }

  // Load messages for a specific match
  Future<void> loadMessages(String otherUserId) async {
    try {
      _setLoading(true);
      _clearError();

      // Listen to messages stream
      ChatService.getMessages(otherUserId).listen(
        (messages) {
          _currentChatMessages = messages;
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load messages: $error');
        },
      );
    } catch (e) {
      _setError('Failed to load messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String receiverId,
    required String message,
    String messageType = 'text',
    String? replyToMessageId,
  }) async {
    try {
      _clearError();

      await ChatService.sendMessage(
        receiverId: receiverId,
        message: message,
        messageType: messageType,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      _setError('Failed to send message: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      await ChatService.markMessagesAsRead(otherUserId);
    } catch (e) {
      _setError('Failed to mark messages as read: $e');
    }
  }

  // Create a match between two users
  Future<void> createMatch(
      String user1Id, String user2Id, BuildContext? context) async {
    try {
      _clearError();

      await ChatService.createMatch(user1Id, user2Id);

      // Get profiles for the match popup
      final user1Profile = await ProfileProvider().getProfile(user1Id);
      final user2Profile = await ProfileProvider().getProfile(user2Id);

      // Show match popup for both users if context is available
      if (context != null && user1Profile != null && user2Profile != null) {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Determine which user is the current user and show popup for them
          if (currentUser.uid == user1Id) {
            // Show popup for user1 with user2's info
            SimpleNotificationService.showMatchPopup(
              context: context,
              matchedUserName: user2Profile.name,
              matchedUserPhotoUrl: user2Profile.photoUrl,
              onTap: () {
                // Navigate to chat with the matched user
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {
                    'otherUserId': user2Id,
                    'otherUserName': user2Profile.name,
                    'otherUserPhotoUrl': user2Profile.photoUrl,
                  },
                );
              },
            );
          } else if (currentUser.uid == user2Id) {
            // Show popup for user2 with user1's info
            SimpleNotificationService.showMatchPopup(
              context: context,
              matchedUserName: user1Profile.name,
              matchedUserPhotoUrl: user1Profile.photoUrl,
              onTap: () {
                // Navigate to chat with the matched user
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {
                    'otherUserId': user1Id,
                    'otherUserName': user1Profile.name,
                    'otherUserPhotoUrl': user1Profile.photoUrl,
                  },
                );
              },
            );
          }
        }
      }

      // Reload matches to show the new match
      await loadMatches();
    } catch (e) {
      _setError('Failed to create match: $e');
    }
  }

  // Check if two users are matched
  Future<bool> areUsersMatched(String userId1, String userId2) async {
    try {
      final match = await ChatService.getMatch(userId1, userId2);
      return match != null;
    } catch (e) {
      debugPrint('Error checking if users are matched: $e');
      return false;
    }
  }

  // Delete a match
  Future<void> deleteMatch(String userId1, String userId2) async {
    try {
      _clearError();
      await ChatService.deleteMatch(userId1, userId2);
    } catch (e) {
      _setError('Failed to delete match: $e');
    }
  }

  // Get unread count for a match
  int getUnreadCount(String matchId, String currentUserId) {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      return match.unreadCount[currentUserId] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get total unread count
  int getTotalUnreadCount() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      int total = 0;
      for (final match in _matches) {
        total += match.unreadCount[currentUser.uid] ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // Get last message for a match
  String getLastMessage(String matchId) {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      if (match.lastMessageId != null) {
        final lastMessage = _currentChatMessages
            .where((msg) => msg.id == match.lastMessageId)
            .firstOrNull;
        return lastMessage?.message ?? 'No messages yet';
      }
      return 'No messages yet';
    } catch (e) {
      return 'No messages yet';
    }
  }

  // Get last message time for a match
  DateTime? getLastMessageTime(String matchId) {
    try {
      final match = _matches.firstWhere((m) => m.id == matchId);
      return match.lastMessageAt;
    } catch (e) {
      return null;
    }
  }

  // Clear current chat messages
  void clearCurrentChat() {
    _currentChatMessages = [];
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
