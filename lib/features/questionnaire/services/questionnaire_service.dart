import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionnaireService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveResponses(Map<String, dynamic> responses) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    await _db.collection('questionnaires').doc(uid).set(responses);
  }
}
