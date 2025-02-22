import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String challengeId;
  final String title;
  final String description;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  // ✅ Factory constructor to create an instance from Firestore data
  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: docId,
      userId: data['userId'] ?? "Unknown",
      challengeId: data['challengeId'] ?? "",
      title: data['title'] ?? "No Title",
      description: data['description'] ?? "No Description",
      type: data['type'] ?? "general",
      isRead: data['isRead'] ?? false, // ✅ Default to false
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // ✅ Ensure default value
    );
  }

  // ✅ Convert an instance into a Firestore document
  Map<String, dynamic> toFirestore({bool isNew = false}) {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'title': title,
      'description': description,
      'type': type,
      'isRead': isRead,
      'createdAt': isNew ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt), // ✅ Consistent timestamp handling
    };
  }

  // ✅ Copy method for immutability support
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? challengeId,
    String? title,
    String? description,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
