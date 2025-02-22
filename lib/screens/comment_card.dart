import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final String commentText;
  final String userId;
  final Timestamp timestamp;
  final FirebaseFirestore firestore;

  const CommentCard({
    Key? key,
    required this.commentText,
    required this.userId,
    required this.timestamp,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(commentText),
        subtitle: Text('By Anonymous - ${timestamp.toDate()}'),  // Display "Anonymous" if no user name
      ),
    );
  }
}

