import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>>
      get interviewCollection =>
          _firestore
              .collection('users')
              .doc(uid)
              .collection('interviews');

  Future<void> saveInterview({
    required String role,
    required int score,
    required String question,
    required String answer,
    required String feedback,
    required int timeTaken,
  }) async {
    await interviewCollection.add({
      'role': role,
      'score': score,
      'question': question,
      'answer': answer,
      'feedback': feedback,
      'timeTaken': timeTaken,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getInterviewHistory() {
    return interviewCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}