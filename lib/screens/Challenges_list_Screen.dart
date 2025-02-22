import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class ChallengesScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
        backgroundColor: const Color(0xFF55883B), // 🌱 Eco-Friendly Green
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getChallengesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9A6735)), // 🌿 Earthy Brown Spinner
            );
          }
          if (snapshot.hasError) {
            return _buildMessage("Error loading challenges 😢", Colors.red);
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildMessage("No challenges available 🧐", Colors.grey);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              var challenge = snapshot.data!.docs[index];
              return _buildChallengeTile(context, challenge);
            },
          );
        },
      ),
    );
  }

  /// ✅ Extracted method for error/no data messages
  Widget _buildMessage(String message, Color color) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  /// ✅ Improved Challenge Tile UI with Voting Status Indicator and Safe Voting Handling
  Widget _buildChallengeTile(BuildContext context, DocumentSnapshot challenge) {
    Map<String, dynamic>? data = challenge.data() as Map<String, dynamic>?;

    String title = data?['title'] ?? "Untitled Challenge";
    String description = data?['description'] ?? "No description available";
    int votes = data?['votes'] ?? 0;
    String userId = data?['userId'] ?? "Unknown User";
    List<dynamic> votedUsers = data?['votedUsers'] ?? [];
    String currentUser = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";

    bool userVoted = votedUsers.contains(currentUser);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "$description\nPosted by: $userId",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leading: const Icon(Icons.eco, color: Color(0xFF55883B)), // 🌱 Green Icon
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.thumb_up,
                color: userVoted ? Colors.blueAccent : Colors.grey,
              ),
              onPressed: () => _voteChallenge(context, challenge.id, votes, userVoted),
            ),
            Text(
              '$votes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔼🔽 Handles upvote functionality safely with user tracking
  void _voteChallenge(BuildContext context, String docId, int currentVotes, bool userVoted) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
    DocumentReference challengeRef = FirebaseFirestore.instance.collection("challenges").doc(docId);

    try {
      // Show a loading indicator or feedback
      final snackBar = SnackBar(content: Text(userVoted ? "Removing vote..." : "Adding vote..."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (userVoted) {
        // Remove vote if already voted
        await challengeRef.update({
          "votes": FieldValue.increment(-1),
          "votedUsers": FieldValue.arrayRemove([userId]),
        });
      } else {
        // Add vote if user hasn't voted
        await challengeRef.update({
          "votes": FieldValue.increment(1),
          "votedUsers": FieldValue.arrayUnion([userId]),
        });
      }

      // Show a confirmation message after updating
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(userVoted ? "Vote removed successfully" : "Vote added successfully"),
      ));
    } catch (error) {
      // Error handling for Firestore update
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error voting. Please try again later."),
        backgroundColor: Colors.red,
      ));
    }
  }
}
