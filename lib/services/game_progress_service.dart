import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameProgressService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> updateProgress(Map<String, dynamic> newData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    await docRef.set({
      'progress': newData,
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getProgress() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return Map<String, dynamic>.from(doc.data()?['progress'] ?? {});
  }
}
