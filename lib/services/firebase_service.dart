import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches real-time challenges from Firestore, ordered by latest first.
  Stream<QuerySnapshot> getChallengesStream() {
    return _firestore
        .collection('challenges')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Fetch notifications as a stream, filtered by `userId`, ordered by latest first.
  Stream<QuerySnapshot> getNotificationsStream({required String userId}) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Fetch count of unread notifications for a user.
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      return snapshot.size;
    } catch (e) {
      debugPrint("❌ Error fetching unread count: $e");
      return 0;
    }
  }

  /// Add a new notification to Firestore.
  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    if (title.trim().isEmpty || message.trim().isEmpty) {
      debugPrint("⚠️ Cannot add an empty notification.");
      return;
    }

    try {
      String docId = _firestore.collection('notifications').doc().id;
      await _firestore.collection('notifications').doc(docId).set({
        'userId': userId,
        'title': title.trim(),
        'description': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      debugPrint("✅ Notification added successfully.");
    } catch (e) {
      debugPrint("❌ Error adding notification: $e");
    }
  }

  /// Delete a notification by its document ID.
  Future<void> deleteNotification(String docId) async {
    try {
      await _firestore.collection('notifications').doc(docId).delete();
      debugPrint("🗑️ Notification deleted: $docId");
    } catch (e) {
      debugPrint("❌ Error deleting notification: $e");
    }
  }

  /// Update a notification with custom fields.
  Future<void> updateNotification(String docId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('notifications').doc(docId).update(updates);
      debugPrint("✅ Notification updated: $docId");
    } catch (e) {
      debugPrint("❌ Error updating notification: $e");
    }
  }

  /// Mark a single notification as read using a transaction.
  Future<void> markNotificationAsRead(String docId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('notifications').doc(docId);
        transaction.update(docRef, {'isRead': true});
      });
      debugPrint("✅ Notification marked as read: $docId");
    } catch (e, stackTrace) {
      debugPrint("❌ Error marking notification as read: $e\n$stackTrace");
    }
  }

  /// Mark all unread notifications as read using batch write.
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      // Limiting to a batch of 500 documents to avoid overwhelming Firestore.
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .limit(500)  // Limit the number of docs to process at once
          .get();

      if (snapshot.docs.isEmpty) return;

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      debugPrint("✅ All unread notifications marked as read.");
    } catch (e) {
      debugPrint("❌ Error marking notifications as read: $e");
    }
  }
}

