import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scroll reveal waits for visibility and runs only once', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    const revealKey = ValueKey('below-fold');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scroll,
            child: const Column(
              children: [
                SizedBox(height: 1200),
                Entrance(
                  key: revealKey,
                  child: SizedBox(height: 150, child: Text('Scroll evidence')),
                ),
                SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      ),
    );
    final opacity = find.descendant(
      of: find.byKey(revealKey),
      matching: find.byType(Opacity),
    );
    await tester.pump(const Duration(seconds: 2));
    // Waiting on page load must not consume a below-fold animation.
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    scroll.jumpTo(1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.widget<Opacity>(opacity).opacity, inExclusiveRange(.77, 1));
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    scroll.jumpTo(0);
    await tester.pump();
    scroll.jumpTo(1000);
    await tester.pump();
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps scroll content and controls static', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: Design.theme,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Entrance(
              child: Column(
                children: [
                  const Text('Always readable'),
                  FilledButton(onPressed: () {}, child: const Text('Action')),
                  MotionSurface(onTap: () {}, child: const Text('Card')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Opacity), findsNothing);
    expect(find.byType(AnimatedScale), findsNothing);
    final press = await tester.startGesture(
      tester.getCenter(find.text('Card')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final transforms = tester.widgetList<Transform>(
      find.descendant(
        of: find.byType(MotionSurface),
        matching: find.byType(Transform),
      ),
    );
    for (final transform in transforms) {
      expect(transform.transform.isIdentity(), isTrue);
    }
    await press.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'button motion preserves tap targets and keyboard activation',
    (tester) async {
      var calls = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: Design.theme,
          home: Scaffold(
            body: Center(
              child: FilledButton(
                focusNode: focus,
                onPressed: () => calls++,
                child: const Text('Preview'),
              ),
            ),
          ),
        ),
      );
      final button = find.byType(FilledButton);
      final size = tester.getSize(button);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        .93,
      );
      expect(tester.getSize(button), size);
      expect(size.height, greaterThanOrEqualTo(48));
      expect(calls, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 1);
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets('card press cancellation and keyboard action remain native', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: Design.theme,
        home: Scaffold(
          body: Center(
            child: MotionSurface(
              onTap: () => calls++,
              child: const SizedBox(
                width: 200,
                height: 120,
                child: Text('Case study'),
              ),
            ),
          ),
        ),
      ),
    );
    final card = find.byType(MotionSurface);
    final size = tester.getSize(card);
    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.getSize(card), size);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('outgoing previews lose their actions during a transition', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final oldFocus = FocusNode(), newFocus = FocusNode();
    addTearDown(oldFocus.dispose);
    addTearDown(newFocus.dispose);
    var current = 0;
    late StateSetter change;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            change = setState;
            return Scaffold(
              body: MotionSwap(
                child: TextButton(
                  key: ValueKey(current),
                  focusNode: current == 0 ? oldFocus : newFocus,
                  onPressed: () {},
                  child: Text('Preview $current'),
                ),
              ),
            );
          },
        ),
      ),
    );
    change(() => current = 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    final old = find.ancestor(
      of: find.text('Preview 0'),
      matching: find.byType(IgnorePointer),
    );
    expect(
      tester.widgetList<IgnorePointer>(old).any((widget) => widget.ignoring),
      isTrue,
    );
    expect(find.bySemanticsLabel('Preview 0'), findsNothing);
    expect(find.bySemanticsLabel('Preview 1'), findsOneWidget);
    expect(oldFocus.canRequestFocus, isFalse);
    expect(newFocus.canRequestFocus, isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Preview 0'), findsNothing);
    semantics.dispose();
  });
}
