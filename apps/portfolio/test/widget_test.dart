import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show SemanticsAction;
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final width in [320.0, 768.0, 1280.0, 1920.0]) {
    testWidgets('portfolio lays out at $width pixels with no overflow', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        debugPrint(details.toString());
        previousErrorHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousErrorHandler);
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => FirestoreService.initialize());
      await tester.pumpWidget(const PortfolioApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ahmed Emara'), findsWidgets);
      expect(find.text('View Projects'), findsOneWidget);
      expect(find.text('Download CV'), findsOneWidget);
      await tester.ensureVisible(find.text('All projects (11)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All projects (11)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Work in the wild.'), findsOneWidget);
    });
  }
  testWidgets('reduced motion leaves all content visible', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => FirestoreService.initialize());
    await tester.pumpWidget(
      MaterialApp(
        theme: Design.theme,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Entrance(child: Text('Visible content')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Visible content'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });
  testWidgets(
    'gallery exposes a working accessible action and keyboard controls',
    (tester) async {
      final handle = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => FirestoreService.initialize());
      final rows = await FirestoreService.collectionStreamWithIds(
        'projects',
      ).first;
      final row = rows.firstWhere((e) => e.value['slug'] == 'be-fit');
      final project = ProjectModel.fromMap(row.value, row.key);
      await tester.pumpWidget(
        MaterialApp(
          theme: Design.theme,
          home: Scaffold(body: ProjectDetail(project: project)),
        ),
      );
      await tester.pumpAndSettle();
      final button = find.bySemanticsLabel(
        'View Be Fit exercise list full size',
      );
      await tester.ensureVisible(button);
      final node = tester.getSemantics(button);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.tap,
      );
      await tester.pumpAndSettle();
      expect(find.text('Be Fit · 1 / 4'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Be Fit · 2 / 4'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(GalleryViewer), findsNothing);
      expect(tester.takeException(), isNull);
      handle.dispose();
    },
  );
}
