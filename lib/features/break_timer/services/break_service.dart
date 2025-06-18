import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BreakService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchBreakData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('breaks').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> endBreakEarly() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('breaks').doc(uid).update({
      'ended_early': true,
      'end_time': DateTime.now(),
    });
  }
}
