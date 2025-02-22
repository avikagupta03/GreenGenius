import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final DateTime timestamp;

  NotificationTile({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 6),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        leading: Icon(Icons.notifications, color: Colors.blueAccent),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}  ${timestamp.hour}:${timestamp.minute}";
  }
}
