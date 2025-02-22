import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return _buildScaffold(_buildMessage("User not logged in.", Colors.red));
    }

    return _buildScaffold(
      StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getNotificationsStream(userId: _userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError) {
            return _buildErrorMessage(snapshot.error.toString());
          }

          final notifications = snapshot.data?.docs ?? [];
          if (notifications.isEmpty) {
            return _buildMessage("No notifications available 🧐", Colors.grey);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildDismissibleNotification(notifications[index]);
            },
          );
        },
      ),
    );
  }

  /// Builds the Scaffold structure with an AppBar.
  Scaffold _buildScaffold(Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: const Color(0xFF55883B),
      ),
      body: body,
    );
  }

  /// Builds a dismissible notification tile.
  Widget _buildDismissibleNotification(QueryDocumentSnapshot notification) {
    String title = notification['title'] ?? "No Title";
    String message = notification['description'] ?? "No Description";
    DateTime timestamp = (notification['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (_) => _showDeleteConfirmation(),
      onDismissed: (_) => _firebaseService.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () => _firebaseService.markNotificationAsRead(notification.id),
        child: NotificationTile(title: title, message: message, timestamp: timestamp),
      ),
    );
  }

  /// Builds the background for the Dismissible widget.
  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  /// Shows a confirmation dialog for deleting a notification.
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Notification?"),
        content: const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// Displays a loading indicator.
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF9A6735)),
    );
  }

  /// Displays an error message.
  Widget _buildErrorMessage(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Error loading notifications 😢\n$error",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () => setState(() {}), child: const Text("Retry")),
        ],
      ),
    );
  }

  /// Displays a generic message.
  Widget _buildMessage(String message, Color color) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
