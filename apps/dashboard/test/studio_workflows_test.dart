import 'dart:async';
import 'package:core/core.dart';
import 'package:dashboard/content_schema.dart';
import 'package:dashboard/pages/collection_page.dart';
import 'package:dashboard/services/studio_content.dart';
import 'package:dashboard/theme/dashboard_theme.dart';
import 'package:dashboard/widgets/record_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> openEditor(
  WidgetTester tester,
  ContentSchema schema,
  MapEntry<String, Map<String, dynamic>> record,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 1000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: DashboardTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecordEditor(
                  schema: schema,
                  id: record.key,
                  initial: record.value,
                ),
              ),
            ),
            child: const Text('Open editor'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

Future<void> saveEditor(WidgetTester tester) async {
  await tester.runAsync(() async {
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save changes'),
        matching: find.byType(FilledButton),
      ),
    );
    await (button.onPressed! as Future<void> Function())();
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FirestoreService.initialize();
  });

  test(
    'studio home page lineup agrees with public queries and omits featured drafts',
    () async {
      await FirestoreService.setDocument('projects', 'featured-draft', {
        'title': 'Private fixture',
        'slug': 'private-fixture',
        'status': 'draft',
        'featured': true,
        'featuredOrder': -1,
        'order': 99,
      });
      final content = StudioContent();
      addTearDown(content.dispose);
      final ready = Completer<void>();
      void check() {
        if (!content.loading && !ready.isCompleted) ready.complete();
      }

      content.addListener(check);
      await ready.future.timeout(const Duration(seconds: 5));
      final public =
          (await FirestoreService.collectionStreamWithIds(
            'projects',
            publishedOnly: true,
          ).first).where((e) => e.value['featured'] == true).toList()..sort(
            (a, b) => (a.value['featuredOrder'] as num).compareTo(
              b.value['featuredOrder'] as num,
            ),
          );
      expect(
        content.featured.map((p) => p.id),
        public.take(4).map((e) => e.key),
      );
      expect(content.projects.any((p) => p.id == 'featured-draft'), isTrue);
      expect(content.featured.any((p) => p.id == 'featured-draft'), isFalse);
      expect(await FirestoreService.publicProject('private-fixture'), isNull);
    },
  );

  testWidgets(
    'named project selections persist as references and keep unavailable references and legacy data',
    (tester) async {
      final initial = (await FirestoreService.collectionStreamWithIds(
        'technical_skills',
      ).first).first;
      final fixId = (await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first).firstWhere((e) => e.value['slug'] == 'fix').key;
      final value = {
        ...initial.value,
        'projectIds': ['unavailable-project'],
        'legacyMarker': 'keep me',
      };
      await openEditor(tester, schemas[3], MapEntry(initial.key, value));
      final fix = find.widgetWithText(CheckboxListTile, 'FIX');
      await tester.ensureVisible(fix);
      await tester.tap(fix);
      await tester.pumpAndSettle();
      await saveEditor(tester);
      await tester.runAsync(() => FirestoreService.initialize());
      final saved = (await FirestoreService.collectionStreamWithIds(
        'technical_skills',
      ).first).firstWhere((e) => e.key == initial.key).value;
      expect(saved['projectIds'], containsAll(['unavailable-project', fixId]));
      expect(saved['legacyMarker'], 'keep me');
      expect(saved['items'], initial.value['items']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'choosing featured projects appends without changing collection order or publishing drafts',
    (tester) async {
      await tester.runAsync(
        () => FirestoreService.setDocument('projects', 'selection-draft', {
          'title': 'Private selection',
          'slug': 'private-selection',
          'status': 'draft',
          'order': 99,
        }),
      );
      final before = await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first;
      final sitr = before.firstWhere((e) => e.value['slug'] == 'sitr');
      await tester.pumpWidget(
        MaterialApp(
          theme: DashboardTheme.light,
          home: const Scaffold(
            body: CollectionPage(schema: projectSchema, featuredOnly: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose projects').first);
      await tester.pumpAndSettle();
      Future<void> choose(String name) async {
        final checkbox = find.widgetWithText(CheckboxListTile, name);
        await tester.scrollUntilVisible(
          checkbox,
          180,
          scrollable: find
              .descendant(
                of: find.byType(Dialog),
                matching: find.byType(Scrollable),
              )
              .last,
        );
        await tester.runAsync(() async {
          final tile = tester.widget<CheckboxListTile>(checkbox);
          await (tile.onChanged! as Future<void> Function(bool?))(true);
        });
        await tester.pumpAndSettle();
      }

      await choose(sitr.value['title'] as String);
      await choose('Private selection');
      await tester.runAsync(() => FirestoreService.initialize());
      final after = await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first;
      expect(after.map((e) => e.key), before.map((e) => e.key));
      expect(
        after.firstWhere((e) => e.key == sitr.key).value['featuredOrder'],
        4,
      );
      expect(
        after.firstWhere((e) => e.key == 'selection-draft').value['status'],
        'draft',
      );
      expect(
        after.firstWhere((e) => e.key == 'selection-draft').value['featured'],
        isTrue,
      );
      expect(await FirestoreService.publicProject('private-selection'), isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'clearing an optional thumbnail preserves a usable public screenshot across reload',
    (tester) async {
      final initial = (await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first).firstWhere((e) => e.value['slug'] == 'fix');
      await openEditor(tester, projectSchema, initial);
      final thumbnail = find
          .byWidgetPredicate(
            (w) =>
                w is TextField &&
                w.decoration?.labelText == 'Optimized thumbnail URL (optional)',
          )
          .first;
      await tester.ensureVisible(thumbnail);
      await tester.enterText(thumbnail, '');
      await tester.pumpAndSettle();
      await saveEditor(tester);
      await tester.runAsync(() => FirestoreService.initialize());
      final published = await FirestoreService.publicProject('fix');
      final gallery = published!.value['gallery'] as List;
      expect(
        gallery.first['url'],
        (initial.value['gallery'] as List).first['url'],
      );
      expect(
        gallery.first['thumbnail'] ?? gallery.first['url'],
        gallery.first['url'],
      );
      expect(published.value['googlePlayUrl'], initial.value['googlePlayUrl']);
      expect(published.value['appStoreUrl'], initial.value['appStoreUrl']);
      expect(tester.takeException(), isNull);
    },
  );
}
