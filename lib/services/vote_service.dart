import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> castVote(String challengeId, String? currentUserId, String? userVote, String type) async {
    if (currentUserId == null || userVote != null) {
      // Handle already voted scenario
      throw Exception("You have already voted!");
    }

    DocumentReference challengeRef = _firestore.collection("challenges").doc(challengeId);
    DocumentReference userVoteRef = challengeRef.collection("votes").doc(currentUserId);

    try {
      int voteChange = (type == "upvote") ? 1 : -1;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(challengeRef, {"votes": FieldValue.increment(voteChange)});
        transaction.set(userVoteRef, {"vote": type, "timestamp": FieldValue.serverTimestamp()});
      });
    } catch (e) {
      throw Exception("Error updating vote: ${e.toString()}");
    }
  }
}
