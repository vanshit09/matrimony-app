import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/match.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _matchesCollection = 'matches';

  // Send a message
  static Future<void> sendMessage({
    required String receiverId,
    required String message,
    String messageType = 'text',
    String? replyToMessageId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final messageId = const Uuid().v4();
      final chatMessage = ChatMessage(
        id: messageId,
        senderId: currentUser.uid,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        messageType: messageType,
        replyToMessageId: replyToMessageId,
      );

      // Create a chat room ID for the two users
      final chatRoomId = _generateChatRoomId(currentUser.uid, receiverId);

      // Save message to Firestore in the chat room
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(chatMessage.toMap());

      // Update match with last message info
      await _updateMatchLastMessage(currentUser.uid, receiverId, messageId);

      // Update unread count for receiver
      await _incrementUnreadCount(receiverId, currentUser.uid);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages between two users
  static Stream<List<ChatMessage>> getMessages(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Create a chat room ID for the two users
    final chatRoomId = _generateChatRoomId(currentUser.uid, otherUserId);

    // Get messages from the chat room - no complex indexes needed
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final chatRoomId = _generateChatRoomId(currentUser.uid, otherUserId);

      // Get all unread messages from the other user in the chat room
      final unreadMessages = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Update each message as read
      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count
      await _resetUnreadCount(currentUser.uid, otherUserId);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Create a match between two users
  static Future<void> createMatch(String user1Id, String user2Id) async {
    try {
      final matchId = _generateMatchId(user1Id, user2Id);
      final match = Match(
        id: matchId,
        user1Id: user1Id,
        user2Id: user2Id,
        matchedAt: DateTime.now(),
      );

      await _firestore
          .collection(_matchesCollection)
          .doc(matchId)
          .set(match.toMap());

      // Update user profiles with match
      await _updateUserMatches(user1Id, user2Id);
      await _updateUserMatches(user2Id, user1Id);
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  // Get matches for current user
  static Stream<List<Match>> getMatches() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection(_matchesCollection)
        .where('user1Id', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncExpand((user1Matches) {
      return _firestore
          .collection(_matchesCollection)
          .where('user2Id', isEqualTo: currentUser.uid)
          .snapshots()
          .map((user2Matches) {
        final allMatches = <Match>[];
        allMatches
            .addAll(user1Matches.docs.map((doc) => Match.fromMap(doc.data())));
        allMatches
            .addAll(user2Matches.docs.map((doc) => Match.fromMap(doc.data())));
        return allMatches;
      });
    });
  }

  // Get match between two users
  static Future<Match?> getMatch(String userId1, String userId2) async {
    try {
      final matchId = _generateMatchId(userId1, userId2);
      final doc =
          await _firestore.collection(_matchesCollection).doc(matchId).get();

      if (doc.exists) {
        return Match.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get match: $e');
    }
  }

  // Delete match
  static Future<void> deleteMatch(String userId1, String userId2) async {
    try {
      final matchId = _generateMatchId(userId1, userId2);
      await _firestore.collection(_matchesCollection).doc(matchId).delete();

      // Remove from user profiles
      await _removeUserMatch(userId1, userId2);
      await _removeUserMatch(userId2, userId1);
    } catch (e) {
      throw Exception('Failed to delete match: $e');
    }
  }

  // Helper methods
  static String _generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  static String _generateChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  static Future<void> _updateMatchLastMessage(
      String senderId, String receiverId, String messageId) async {
    try {
      final matchId = _generateMatchId(senderId, receiverId);
      await _firestore.collection(_matchesCollection).doc(matchId).update({
        'lastMessageId': messageId,
        'lastMessageAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Match might not exist yet, ignore error
    }
  }

  static Future<void> _incrementUnreadCount(
      String receiverId, String senderId) async {
    try {
      final matchId = _generateMatchId(senderId, receiverId);
      await _firestore.collection(_matchesCollection).doc(matchId).update({
        'unreadCount.$receiverId': FieldValue.increment(1),
      });
    } catch (e) {
      // Match might not exist yet, ignore error
    }
  }

  static Future<void> _resetUnreadCount(
      String userId, String otherUserId) async {
    try {
      final matchId = _generateMatchId(userId, otherUserId);
      await _firestore.collection(_matchesCollection).doc(matchId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      // Match might not exist yet, ignore error
    }
  }

  static Future<void> _updateUserMatches(
      String userId, String matchUserId) async {
    try {
      await _firestore.collection('profiles').doc(userId).update({
        'matches': FieldValue.arrayUnion([matchUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update user matches: $e');
    }
  }

  static Future<void> _removeUserMatch(
      String userId, String matchUserId) async {
    try {
      await _firestore.collection('profiles').doc(userId).update({
        'matches': FieldValue.arrayRemove([matchUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to remove user match: $e');
    }
  }
}
