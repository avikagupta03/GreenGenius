import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  Map<String, Map<String, dynamic>> _deletedNotifications = {}; // Stores deleted notifications for undo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getNotificationsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }
          if (snapshot.hasError) {
            return _buildErrorMessage(snapshot.error);
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildMessage("No notifications available 🧐", Colors.grey);
          }
          return _buildNotificationList(snapshot.data!.docs);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Notifications"),
      centerTitle: true,
      backgroundColor: const Color(0xFF55883B),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF9A6735)),
    );
  }

  Widget _buildNotificationList(List<QueryDocumentSnapshot> docs) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var notification = docs[index];
        var data = notification.data() as Map<String, dynamic>? ?? {};

        return _buildDismissibleNotification(
          notification.id,
          data: data,
        );
      },
    );
  }

  Widget _buildDismissibleNotification(String id, {required Map<String, dynamic> data}) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (direction) async => await _showDeleteConfirmation(),
      onDismissed: (direction) => _handleNotificationDelete(id, data),
      child: NotificationTile(
        title: data["title"] as String? ?? "No Title",
        message: data["description"] as String? ?? "No Description",
        timestamp: (data["timestamp"] as Timestamp?)?.toDate() ?? DateTime(2000, 1, 1),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification?"),
        content: const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _handleNotificationDelete(String id, Map<String, dynamic> data) {
    // Save deleted notification data
    _deletedNotifications[id] = data;

    _notificationService.deleteNotification(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Notification deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () => _handleUndo(id),
        ),
      ),
    );
  }

  void _handleUndo(String id) {
    if (_deletedNotifications.containsKey(id)) {
      _notificationService.restoreNotification(_deletedNotifications[id]!);
      _deletedNotifications.remove(id);
    }
  }

  Widget _buildErrorMessage(dynamic error) {
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
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message, Color color) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
