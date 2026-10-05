import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FirestoreService.initialize();
  });
  test('profile writes survive reload and preserve other fields', () async {
    final before = await FirestoreService.profileStream().first;
    await FirestoreService.updateProfile({
      'availabilityNote': 'Updated availability',
    });
    await FirestoreService.initialize();
    final after = await FirestoreService.profileStream().first;
    expect(after!['availabilityNote'], 'Updated availability');
    expect(after['contactEmail'], before!['contactEmail']);
  });
  test('drafts stay private on public queries and direct lookup', () async {
    await FirestoreService.setDocument('projects', 'test-draft', {
      'title': 'Private',
      'slug': 'private-test',
      'status': 'draft',
      'order': 100,
    });
    expect(
      (await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first).any((e) => e.key == 'test-draft'),
      isTrue,
    );
    expect(
      (await FirestoreService.collectionStreamWithIds(
        'projects',
        publishedOnly: true,
      ).first).any((e) => e.key == 'test-draft'),
      isFalse,
    );
    expect(await FirestoreService.publicProject('private-test'), isNull);
    await FirestoreService.updateDocument('projects', 'test-draft', {
      'status': 'published',
    });
    await FirestoreService.initialize();
    expect(
      (await FirestoreService.publicProject('private-test'))?.key,
      'test-draft',
    );
    await FirestoreService.updateDocument('projects', 'test-draft', {
      'status': 'draft',
    });
    expect(await FirestoreService.publicProject('private-test'), isNull);
  });
  test(
    'published exports omit private data and resolve hosted media safely',
    () async {
      await FirestoreService.setDocument('projects', 'private-export', {
        'title': 'Private export sentinel',
        'slug': 'private-export',
        'status': 'draft',
        'order': 99,
      });
      final snapshot = await FirestoreService.exportPublishedContent();
      expect(jsonEncode(snapshot), isNot(contains('Private export sentinel')));
      expect((snapshot['collections'] as Map).containsKey('messages'), isFalse);
      const path = 'storage://projects/published/screenshot.webp';
      final exported =
          FirestoreService.exportValue({
                'gallery': [
                  {'url': path, 'alt': 'A verified screen'},
                ],
                'description': path,
                'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 5)),
              }, storageBucket: 'portfolio-test.appspot.com')
              as Map;
      final image = Uri.parse((exported['gallery'] as List).first['url']);
      expect(image.scheme, 'https');
      expect(image.host, 'firebasestorage.googleapis.com');
      expect(image.queryParameters['alt'], 'media');
      expect(image.queryParameters.containsKey('token'), isFalse);
      expect(exported['description'], path);
      expect(exported['updatedAt'], '2026-10-05T00:00:00.000Z');
      expect(() => jsonEncode(exported), returnsNormally);
    },
  );
  test(
    'atomic order changes persist and invalid orders leave content intact',
    () async {
      final before = await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first;
      final ids = before.map((e) => e.key).toList().reversed.toList();
      await FirestoreService.reorder('projects', ids);
      await FirestoreService.initialize();
      expect(
        (await FirestoreService.collectionStreamWithIds(
          'projects',
        ).first).map((e) => e.key),
        ids,
      );
      await expectLater(
        FirestoreService.reorder('projects', [ids.first, ids.first]),
        throwsArgumentError,
      );
      await expectLater(
        FirestoreService.reorder('projects', ['nonexistent']),
        throwsStateError,
      );
      expect(
        (await FirestoreService.collectionStreamWithIds(
          'projects',
        ).first).map((e) => e.key),
        ids,
      );
    },
  );
  test('featured ordering is independent of collection ordering', () async {
    final before = await FirestoreService.collectionStreamWithIds(
      'projects',
    ).first;
    final ids = before.take(4).map((e) => e.key).toList().reversed.toList();
    await FirestoreService.reorder('projects', ids, field: 'featuredOrder');
    final after = await FirestoreService.collectionStreamWithIds(
      'projects',
    ).first;
    expect(after.map((e) => e.key), before.map((e) => e.key));
    for (var i = 0; i < ids.length; i++) {
      expect(
        after.firstWhere((e) => e.key == ids[i]).value['featuredOrder'],
        i,
      );
    }
  });
  test('case study extensions retain legacy store links', () {
    final p = ProjectModel.fromMap({
      'title': 'Legacy',
      'googlePlayUrl': 'https://play.google.com/store/apps/details?id=verified',
      'rating': 4,
      'image': 'https://example.test/unverified-image.jpg',
      'order': 2,
    }, 'legacy');
    final edited = p.copyWith(
      role: 'Verified contribution',
      featured: true,
      slug: 'legacy',
    );
    expect(edited.toMap()['googlePlayUrl'], p.googlePlayUrl);
    expect(edited.status, 'published');
    expect(edited.rating, 4);
    expect(edited.image, 'https://example.test/unverified-image.jpg');
    expect(edited.imageKind, 'placeholder');
    expect(
      ProjectModel.fromMap(edited.toMap(), 'legacy').role,
      'Verified contribution',
    );
  });
  test('messages persist, validate fields, and enforce a cooldown', () async {
    await expectLater(
      FirestoreService.submitContactMessage(
        name: 'Test',
        email: 'bad-email',
        subject: 'Hello',
        message: 'Valid message body',
      ),
      throwsArgumentError,
    );
    await FirestoreService.submitContactMessage(
      name: 'Test',
      email: 'test@example.com',
      subject: 'Hello',
      message: 'Valid test message body.',
    );
    await expectLater(
      FirestoreService.submitContactMessage(
        name: 'Test',
        email: 'test@example.com',
        subject: 'Hello',
        message: 'Another valid message body.',
      ),
      throwsStateError,
    );
    await FirestoreService.initialize();
    final messages = await FirestoreService.messagesStream().first;
    expect(messages.length, 1);
    await FirestoreService.markMessageRead(messages.first.key);
    expect(await FirestoreService.unreadMessagesCountStream().first, 0);
  });
  test(
    'all featured projects have verified galleries and no invented outcomes',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final content = jsonDecode(
        preferences.getString(FirestoreService.localKey)!,
      );
      final projects = (content['collections']['projects'] as Map).values;
      expect(projects.where((p) => p['featured'] == true).length, 4);
      for (final p in projects.where((p) => p['featured'] == true)) {
        expect(p['gallery'], isNotEmpty);
        expect(p['outcomes'], '');
      }
      expect(content['profile']['professionalTitle'], 'Flutter Developer');
      expect(content['profile']['contactEmail'], 'emara8028@gmail.com');
    },
  );
}
