import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'comment_card.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final String challengeId;
  final String creatorId;

  const ChallengeDetailsScreen({Key? key, required this.challengeId, required this.creatorId}) : super(key: key);

  @override
  _ChallengeDetailsScreenState createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController commentController = TextEditingController();

  String? currentUserId;
  String? userVote;
  bool isVoting = false;
  bool isCommenting = false;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
  }

  // Helper method to fetch the user name
  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
    return userSnapshot.exists ? userSnapshot['username'] ?? 'Unknown' : 'Unknown';
  }

  Future<void> _castVote(String type) async {
    if (currentUserId == null || userVote != null || isVoting) {
      _showSnackbar("You have already voted!", Colors.orange);
      return;
    }

    setState(() => isVoting = true);

    DocumentReference challengeRef = _firestore.collection("challenges").doc(widget.challengeId);
    DocumentReference userVoteRef = challengeRef.collection("votes").doc(currentUserId);

    try {
      int voteChange = (type == "upvote") ? 1 : -1;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(challengeRef, {"votes": FieldValue.increment(voteChange)});
        transaction.set(userVoteRef, {"vote": type, "timestamp": FieldValue.serverTimestamp()});
      });

      setState(() => userVote = type);
      _sendNotification("Someone ${type}d your challenge!");
    } catch (e) {
      _showSnackbar("Error updating vote: ${e.toString()}", Colors.red);
    } finally {
      setState(() => isVoting = false);
    }
  }

  Future<void> _addComment() async {
    String comment = commentController.text.trim();
    if (comment.isEmpty || currentUserId == null) {
      _showSnackbar("Comment cannot be empty!", Colors.red);
      return;
    }

    setState(() => isCommenting = true);

    try {
      await _firestore
          .collection("challenges")
          .doc(widget.challengeId)
          .collection("comments")
          .add({
        "text": comment,
        "user_id": currentUserId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      commentController.clear();
      _showSnackbar("✅ Comment added!", Colors.green);

      _sendNotification("Someone commented on your challenge!");
    } catch (e) {
      _showSnackbar("Error adding comment: ${e.toString()}", Colors.red);
    } finally {
      setState(() => isCommenting = false);
    }
  }

  Future<void> _sendNotification(String message) async {
    if (widget.creatorId.isEmpty) return;
    try {
      await _firestore.collection("notifications").doc(widget.creatorId).collection("userNotifications").add({
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showSnackbar("Error sending notification: ${e.toString()}", Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _buildVotesSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("challenges").doc(widget.challengeId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        int votes = snapshot.data!["votes"] ?? 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const Text("Votes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("$votes", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: (userVote == "upvote") ? Colors.green : Colors.grey),
                    onPressed: (userVote == null && !isVoting) ? () => _castVote("upvote") : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: (userVote == "downvote") ? Colors.red : Colors.grey),
                    onPressed: (userVote == null && !isVoting) ? () => _castVote("downvote") : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("challenges")
          .doc(widget.challengeId)
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No comments yet. Be the first!"));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            String commentText = data["text"] ?? "No Comment";
            String userId = data["user_id"] ?? "Unknown User";
            Timestamp? timestamp = data["timestamp"];

            return CommentCard(
              commentText: commentText,
              userId: userId,  // Just pass the userId
              timestamp: timestamp!,
              firestore: _firestore,
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Challenge Details"), backgroundColor: const Color(0xFF55883B)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVotesSection(),
            const SizedBox(height: 20),
            const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(child: _buildCommentsSection()),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Write a comment...",
                suffixIcon: isCommenting
                    ? const CircularProgressIndicator()
                    : IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _addComment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
