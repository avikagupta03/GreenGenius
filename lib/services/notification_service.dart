import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches real-time notifications, ordered by latest first.
  Stream<QuerySnapshot> getNotificationsStream() {
    try {
      return _firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      debugPrint("❌ Error fetching notifications: $e");
      return Stream.error(e);
    }
  }

  /// Adds a new notification (for admin use or testing).
  Future<void> addNotification(String title, String description) async {
    title = title.trim();
    description = description.trim();

    if (title.isEmpty || description.isEmpty) {
      debugPrint("⚠️ Title and description cannot be empty.");
      return;
    }

    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      debugPrint("✅ Notification added successfully.");
    } catch (e) {
      debugPrint("❌ Error adding notification: $e");
    }
  }

  /// Deletes a single notification by its document ID.
  Future<void> deleteNotification(String docId) async {
    try {
      await _firestore.collection('notifications').doc(docId).delete();
      debugPrint("🗑️ Notification deleted successfully.");
    } catch (e) {
      debugPrint("❌ Error deleting notification: $e");
    }
  }

  /// Deletes multiple notifications efficiently using a batch operation.
  Future<void> deleteMultipleNotifications(List<String> docIds) async {
    if (docIds.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    try {
      for (String docId in docIds) {
        batch.delete(_firestore.collection('notifications').doc(docId));
      }
      await batch.commit();
      debugPrint("🗑️✅ Batch deletion successful.");
    } catch (e) {
      debugPrint("❌ Error in batch deletion: $e");
    }
  }

  /// Marks a notification as read using a Firestore transaction.
  Future<void> markAsRead(String docId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference docRef = _firestore.collection('notifications').doc(docId);
        DocumentSnapshot snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          transaction.update(docRef, {'isRead': true});
        } else {
          debugPrint("⚠️ Notification does not exist.");
        }
      });
      debugPrint("✅ Notification marked as read.");
    } catch (e) {
      debugPrint("❌ Error marking notification as read: $e");
    }
  }

  /// Marks multiple notifications as read using a batch update.
  Future<void> markMultipleAsRead(List<String> docIds) async {
    if (docIds.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    try {
      for (String docId in docIds) {
        DocumentReference docRef = _firestore.collection('notifications').doc(docId);
        batch.update(docRef, {'isRead': true});
      }
      await batch.commit();
      debugPrint("✅ All notifications marked as read.");
    } catch (e) {
      debugPrint("❌ Error marking multiple notifications as read: $e");
    }
  }

  /// Restores a deleted notification using its previous data.
  Future<void> restoreNotification(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('notifications').add({
        'title': data['title'] ?? 'No Title',
        'description': data['description'] ?? 'No Description',
        'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
        'isRead': data['isRead'] ?? false,
      });

      debugPrint("🔄 Notification restored successfully.");
    } catch (e) {
      debugPrint("❌ Error restoring notification: $e");
    }
  }
}
