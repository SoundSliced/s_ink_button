import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_ink_button/s_ink_button.dart';

void main() {
  testWidgets('SInkButton calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SInkButton(
          child: const SizedBox(width: 48, height: 48),
          onTap: (_) => tapped = true,
        ),
      ),
    ));

    await tester.tap(find.byType(SInkButton));
    await tester.pumpAndSettle();

    expect(tapped, true);
  });

  testWidgets('SInkButton calls onDoubleTap', (tester) async {
    var count = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SInkButton(
          child: const SizedBox(width: 48, height: 48),
          onDoubleTap: (_) => count++,
        ),
      ),
    ));

    await tester.tap(find.byType(SInkButton));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(SInkButton));
    await tester.pumpAndSettle();

    expect(count, 1);
  });

  testWidgets('SInkButton long press triggers handlers', (tester) async {
    var started = false;
    var ended = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SInkButton(
          child: const SizedBox(width: 48, height: 48),
          onLongPressStart: (_) => started = true,
          onLongPressEnd: (_) => ended = true,
        ),
      ),
    ));

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(SInkButton)));
    await tester.pump(const Duration(seconds: 1));

    expect(started, true);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(ended, true);
  });

  testWidgets('When isActive is false, callbacks are not called',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SInkButton(
          isActive: false,
          onTap: (_) => tapped = true,
          child: const SizedBox(width: 48, height: 48),
        ),
      ),
    ));

    await tester.tap(find.byType(SInkButton));
    await tester.pumpAndSettle();

    expect(tapped, false);
  });
}
