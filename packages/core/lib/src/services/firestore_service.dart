import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Read (streams) ──

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

  static Stream<List<MapEntry<String, Map<String, dynamic>>>>
      collectionStreamWithIds(String name) {
    return _db.collection(name).orderBy('order').snapshots().map(
          (snap) =>
              snap.docs.map((d) => MapEntry(d.id, d.data())).toList(),
        );
  }

  // ── Write (CRUD) ──

  static Future<void> updateProfile(Map<String, dynamic> data) {
    return _db.collection('profile').doc('main').set(data, SetOptions(merge: true));
  }

  static Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  static Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).update(data);
  }

  static Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).set(data);
  }

  static Future<void> deleteDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).delete();
  }

  static Future<int> collectionCount(String collection) async {
    final snap = await _db.collection(collection).count().get();
    return snap.count ?? 0;
  }

  // ── Activity log ──

  static Future<void> logActivity({
    required String action,
    required String entity,
    required String target,
  }) async {
    try {
      await _db.collection('activity').add({
        'action': action,
        'entity': entity,
        'target': target,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // best-effort logging — never block the calling write
    }
  }

  static Stream<List<Map<String, dynamic>>> recentActivityStream({int limit = 5}) {
    return _db
        .collection('activity')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
