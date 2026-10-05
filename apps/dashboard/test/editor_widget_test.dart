import 'package:core/core.dart';
import 'package:dashboard/main.dart';
import 'package:dashboard/content_schema.dart';
import 'package:dashboard/widgets/record_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveChanges(WidgetTester tester) async {
  await tester.runAsync(() async {
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save changes'),
        matching: find.byType(FilledButton),
      ),
    );
    // Await the actual button's platform storage acknowledgement outside fake time.
    await (button.onPressed! as Future<void> Function())();
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final width in [320.0, 768.0, 1280.0, 1920.0]) {
    testWidgets('dashboard layout at $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => FirestoreService.initialize());
      await tester.pumpWidget(const DashboardApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Welcome to your studio.'), findsOneWidget);
    });
  }
  testWidgets(
    'editor protects unsaved changes and persists numeric legacy fields',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => FirestoreService.initialize());
      final entry = (await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first).firstWhere((e) => e.value['slug'] == 'fix');
      await tester.pumpWidget(
        MaterialApp(
          theme: Design.theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordEditor(
                      schema: projectSchema,
                      id: entry.key,
                      initial: entry.value,
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
      final title = find.byWidgetPredicate(
        (w) => w is TextFormField && w.controller?.text == 'FIX',
      );
      await tester.enterText(title, 'FIX test edit');
      await tester.tap(find.byTooltip('Close editor'));
      await tester.pumpAndSettle();
      expect(find.text('Discard unsaved changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      await saveChanges(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Open editor'), findsOneWidget);
      final saved = (await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first).firstWhere((e) => e.key == entry.key);
      expect(saved.value['title'], 'FIX test edit');
      expect(saved.value['rating'], isA<num>());
      expect(saved.value['googlePlayUrl'], entry.value['googlePlayUrl']);
    },
  );
  testWidgets(
    'metadata saves bundled social images and preserves profile content',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => FirestoreService.initialize());
      final initial = (await FirestoreService.profileStream().first)!;
      await tester.pumpWidget(
        MaterialApp(
          theme: Design.theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordEditor(
                      profile: true,
                      schema: const ContentSchema(
                        'profile',
                        'Search & sharing',
                        'profile',
                        'name',
                        '',
                        metadataFields,
                      ),
                      initial: initial,
                    ),
                  ),
                ),
                child: const Text('Open metadata'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open metadata'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextFormField && w.controller?.text == initial['seoTitle'],
        ),
        'Verified metadata title',
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextFormField && w.controller?.text == initial['siteUrl'],
        ),
        '${initial['siteUrl']}/',
      );
      await saveChanges(tester);
      expect(find.text('Open metadata'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() => FirestoreService.initialize());
      final saved = (await FirestoreService.profileStream().first)!;
      expect(saved['seoTitle'], 'Verified metadata title');
      expect(saved['siteUrl'], initial['siteUrl']);
      expect(saved['socialImage'], initial['socialImage']);
      expect(saved['heroTitle'], initial['heroTitle']);
      expect(saved.containsKey('status'), isFalse);
    },
  );
}
