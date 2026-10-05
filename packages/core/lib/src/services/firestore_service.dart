import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../web/browser.dart';

/// Firebase is the default backend. Explicit local previews never connect to
/// production and share one durable browser storage key on the same origin.
class FirestoreService {
  static const useFirebase = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: true,
  );
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');
  static const localKey = 'ahmed-emara-content-v2';
  static final _changes = StreamController<void>.broadcast();
  static Map<String, dynamic> _local = {};
  static SharedPreferences? _preferences;
  static Future<void> _writes = Future.value();
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static const publicCollections = {
    'projects',
    'experiences',
    'packages',
    'education',
    'technical_skills',
    'soft_skills',
    'tools',
    'about_features',
    'stats',
    'social_links',
    'experience_stats',
  };

  static Future<void> initialize() async {
    if (useFirebase) return;
    _preferences = await SharedPreferences.getInstance();
    final stored = _preferences!.getString(localKey);
    final seed = await rootBundle.loadString(
      'packages/core/assets/content.json',
    );
    _local = Map<String, dynamic>.from(jsonDecode(stored ?? seed) as Map);
    if (stored == null) {
      final ok = await _preferences!.setString(localKey, jsonEncode(_local));
      if (!ok) throw StateError('Browser storage is unavailable.');
    }
    watchStorage(localKey, () async {
      await _preferences!.reload();
      final value = _preferences!.getString(localKey);
      if (value != null) {
        _local = Map<String, dynamic>.from(jsonDecode(value) as Map);
        _changes.add(null);
      }
    });
  }

  static bool isPublished(Map<String, dynamic> data) =>
      data['status'] == null || data['status'] == 'published';

  static List<MapEntry<String, Map<String, dynamic>>> ordered(
    Iterable<MapEntry<String, Map<String, dynamic>>> entries,
  ) {
    final list = entries.toList();
    list.sort((a, b) {
      final result = ((a.value['order'] as num?) ?? 0).compareTo(
        (b.value['order'] as num?) ?? 0,
      );
      return result != 0 ? result : a.key.compareTo(b.key);
    });
    return list;
  }

  static List<MapEntry<String, Map<String, dynamic>>> _entries(String name) {
    final collections = _local['collections'] as Map? ?? {};
    final records = collections[name] as Map? ?? {};
    return ordered(
      records.entries.map(
        (e) => MapEntry(
          e.key.toString(),
          Map<String, dynamic>.from(e.value as Map),
        ),
      ),
    );
  }

  static Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  static Stream<Map<String, dynamic>?> profileStream() {
    if (!useFirebase) {
      return _watch(() => Map<String, dynamic>.from(_local['profile'] as Map));
    }
    return _db
        .collection('profile')
        .doc('main')
        .snapshots()
        .map((s) => s.data());
  }

  static Stream<List<MapEntry<String, Map<String, dynamic>>>>
  collectionStreamWithIds(String name, {bool publishedOnly = false}) {
    if (!useFirebase) {
      return _watch(
        () => _entries(
          name,
        ).where((e) => !publishedOnly || isPublished(e.value)).toList(),
      );
    }
    Query<Map<String, dynamic>> query = _db.collection(name);
    // Security rules require this constraint. Sort locally to avoid a compound
    // index and to preserve legacy documents that do not have an order field.
    if (publishedOnly) query = query.where('status', isEqualTo: 'published');
    return query.snapshots().map(
      (snap) => ordered(snap.docs.map((d) => MapEntry(d.id, d.data()))),
    );
  }

  static Stream<List<Map<String, dynamic>>> collectionStream(
    String name, {
    bool publishedOnly = false,
  }) => collectionStreamWithIds(
    name,
    publishedOnly: publishedOnly,
  ).map((list) => list.map((e) => e.value).toList());

  static Future<MapEntry<String, Map<String, dynamic>>?> publicProject(
    String slug,
  ) async {
    if (!useFirebase) {
      for (final e in _entries('projects')) {
        if ((e.value['slug'] == slug || e.key == slug) && isPublished(e.value))
          return e;
      }
      return null;
    }
    final snap = await _db
        .collection('projects')
        .where('status', isEqualTo: 'published')
        .get();
    for (final d in snap.docs) {
      if (d.data()['slug'] == slug || d.id == slug)
        return MapEntry(d.id, d.data());
    }
    return null;
  }

  static Future<void> _commit(void Function(Map<String, dynamic>) change) {
    final result = _writes.catchError((_) {}).then((_) async {
      // Re-read before each mutation so changes made by the other app survive.
      await _preferences!.reload();
      final stored = _preferences!.getString(localKey);
      final next = Map<String, dynamic>.from(
        jsonDecode(stored ?? jsonEncode(_local)) as Map,
      );
      change(next);
      if (!await _preferences!.setString(localKey, jsonEncode(next))) {
        throw StateError('Changes could not be stored. Please try again.');
      }
      _local = next;
      _changes.add(null);
    });
    _writes = result;
    return result;
  }

  static Future<Map<String, dynamic>> exportPublishedContent() async {
    final profile = await profileStream().first;
    final collections = <String, dynamic>{};
    for (final name in publicCollections) {
      final entries = await collectionStreamWithIds(
        name,
        publishedOnly: true,
      ).first;
      collections[name] = {for (final entry in entries) entry.key: entry.value};
    }
    return Map<String, dynamic>.from(
      exportValue(
            {'profile': profile ?? {}, 'collections': collections},
            storageBucket: useFirebase
                ? FirebaseStorage.instance.app.options.storageBucket
                : null,
          )
          as Map,
    );
  }

  /// Preserve useful legacy fields while making Firestore values exportable.
  static Object? exportValue(Object? value, {String? storageBucket}) {
    if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is GeoPoint)
      return {'latitude': value.latitude, 'longitude': value.longitude};
    if (value is DocumentReference) return value.path;
    if (value is Map) {
      return value.map((key, item) {
        var exported = exportValue(item, storageBucket: storageBucket);
        if (storageBucket != null &&
            {
              'url',
              'thumbnail',
              'image',
              'heroImage',
              'socialImage',
            }.contains(key) &&
            item is String &&
            item.startsWith('storage://')) {
          final origin = useEmulators
              ? 'http://127.0.0.1:9199'
              : 'https://firebasestorage.googleapis.com';
          // Export only published media, with publication-aware public reads.
          // Do not mint download tokens that could expose an unpublished image.
          exported =
              '$origin/v0/b/${Uri.encodeComponent(storageBucket)}/o/'
              '${Uri.encodeComponent(item.substring(10))}?alt=media';
        }
        return MapEntry(key.toString(), exported);
      });
    }
    if (value is Iterable) {
      return value
          .map((item) => exportValue(item, storageBucket: storageBucket))
          .toList();
    }
    return value;
  }

  static Future<void> updateProfile(Map<String, dynamic> data) {
    if (useFirebase)
      return _db
          .collection('profile')
          .doc('main')
          .set(data, SetOptions(merge: true));
    return _commit((next) => (next['profile'] as Map).addAll(data));
  }

  static Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    if (useFirebase) return (await _db.collection(collection).add(data)).id;
    final id = _dbId();
    await setDocument(collection, id, data);
    return id;
  }

  static String _dbId() => 'local-${DateTime.now().microsecondsSinceEpoch}';

  static Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    if (useFirebase) return _db.collection(collection).doc(docId).update(data);
    return _commit((next) {
      final records = (next['collections'] as Map)[collection] as Map;
      if (!records.containsKey(docId))
        throw StateError('This entry no longer exists.');
      (records[docId] as Map).addAll(data);
    });
  }

  static Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    if (useFirebase)
      return _db
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: true));
    return _commit((next) {
      final records =
          (next['collections'] as Map).putIfAbsent(
                collection,
                () => <String, dynamic>{},
              )
              as Map;
      records[docId] = {...?records[docId] as Map?, ...data};
    });
  }

  static Future<void> deleteDocument(String collection, String docId) {
    if (useFirebase) return _db.collection(collection).doc(docId).delete();
    return _commit(
      (next) => ((next['collections'] as Map)[collection] as Map).remove(docId),
    );
  }

  /// One atomic operation. Buttons offer a keyboard-accessible ordering path.
  static Future<void> reorder(
    String collection,
    List<String> ids, {
    String field = 'order',
  }) async {
    if (!{'order', 'featuredOrder'}.contains(field))
      throw ArgumentError('Invalid ordering field.');
    if (ids.toSet().length != ids.length)
      throw ArgumentError('Duplicate entry in order.');
    if (useFirebase) {
      final batch = _db.batch();
      for (var i = 0; i < ids.length; i++) {
        batch.update(_db.collection(collection).doc(ids[i]), {field: i});
      }
      await batch.commit();
    } else {
      await _commit((next) {
        final records = (next['collections'] as Map)[collection] as Map;
        for (var i = 0; i < ids.length; i++) {
          if (!records.containsKey(ids[i]))
            throw StateError('An entry was removed. Refresh and try again.');
          (records[ids[i]] as Map)[field] = i;
        }
      });
    }
  }

  static Future<int> collectionCount(String collection) async => useFirebase
      ? (await _db.collection(collection).count().get()).count ?? 0
      : _entries(collection).length;

  static Future<void> logActivity({
    required String action,
    required String entity,
    required String target,
  }) async {
    try {
      await addDocument('activity', {
        'action': action,
        'entity': entity,
        'target': target,
        'createdAt': useFirebase
            ? FieldValue.serverTimestamp()
            : DateTime.now().toIso8601String(),
      });
    } catch (_) {
      /* The content write already succeeded. */
    }
  }

  static Stream<List<Map<String, dynamic>>> recentActivityStream({
    int limit = 5,
  }) {
    if (useFirebase)
      return _db
          .collection('activity')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
    return _watch(
      () => _entries('activity').map((e) => e.value).toList()
        ..sort(
          (a, b) =>
              b['createdAt'].toString().compareTo(a['createdAt'].toString()),
        ),
    ).map((list) => list.take(limit).toList());
  }

  static Stream<List<MapEntry<String, Map<String, dynamic>>>> messagesStream() {
    if (useFirebase)
      return _db
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => MapEntry(d.id, d.data())).toList());
    return _watch(
      () => _entries('messages')
        ..sort(
          (a, b) => b.value['createdAt'].toString().compareTo(
            a.value['createdAt'].toString(),
          ),
        ),
    );
  }

  static Future<void> submitContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    if (name.trim().isEmpty ||
        name.length > 100 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ||
        email.length > 254 ||
        subject.length > 160 ||
        message.trim().length < 10 ||
        message.length > 5000) {
      throw ArgumentError('Check the message fields and try again.');
    }
    if (useFirebase) {
      final user =
          FirebaseAuth.instance.currentUser ??
          (await FirebaseAuth.instance.signInAnonymously()).user!;
      final batch = _db.batch();
      batch.set(_db.collection('contact_limits').doc(user.uid), {
        'lastSent': FieldValue.serverTimestamp(),
      });
      batch.set(_db.collection('messages').doc(), {
        'name': name.trim(),
        'email': email.trim(),
        'subject': subject.trim(),
        'message': message.trim(),
        'senderUid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      await batch.commit();
    } else {
      await _commit((next) {
        final collections = next['collections'] as Map;
        final limits =
            collections.putIfAbsent('contact_limits', () => {}) as Map;
        final previous = DateTime.tryParse(
          (limits['lastSent'] ?? '').toString(),
        );
        final now = DateTime.now();
        if (previous != null &&
            now.difference(previous) < const Duration(minutes: 2))
          throw StateError(
            'Please wait two minutes before sending another message.',
          );
        limits['lastSent'] = now.toIso8601String();
        (collections['messages'] as Map)[_dbId()] = {
          'name': name.trim(),
          'email': email.trim(),
          'subject': subject.trim(),
          'message': message.trim(),
          'read': false,
          'createdAt': now.toIso8601String(),
        };
      });
    }
  }

  static Stream<int> unreadMessagesCountStream() => messagesStream().map(
    (s) => s.where((e) => e.value['read'] != true).length,
  );
  static Future<void> markMessageRead(String id, {bool read = true}) =>
      updateDocument('messages', id, {'read': read});
  static Future<void> markMessageReplied(String id) =>
      updateDocument('messages', id, {
        'replied': true,
        'read': true,
        'repliedAt': useFirebase
            ? FieldValue.serverTimestamp()
            : DateTime.now().toIso8601String(),
      });
  static Future<void> deleteMessage(String id) =>
      deleteDocument('messages', id);
}
