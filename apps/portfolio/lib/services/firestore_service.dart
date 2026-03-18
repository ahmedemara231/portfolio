import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<Map<String, dynamic>?> profileStream() {
    return _db.collection('profile').doc('main').snapshots().map(
          (snap) => snap.exists ? snap.data() : null,
        );
  }

  static Stream<List<Map<String, dynamic>>> collectionStream(String name) {
    return _db
        .collection(name)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  static Future<void> submitContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) {
    return _db.collection('messages').add({
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
