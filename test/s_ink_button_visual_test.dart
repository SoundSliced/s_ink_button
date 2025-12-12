import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_ink_button/s_ink_button.dart';

void main() {
  testWidgets('SInkButton maintains pressed state during long press',
      (tester) async {
    bool longPressStarted = false;
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SInkButton(
            scaleFactor: 0.5, // Distinct scale factor
            child: Container(color: Colors.red, width: 100, height: 100),
            onTap: (_) {
              tapped = true;
            },
            onLongPressStart: (_) {
              longPressStarted = true;
            },
          ),
        ),
      ),
    ));

    // Verify tap works first
    await tester.tap(find.byType(SInkButton));
    await tester.pumpAndSettle();
    expect(tapped, true, reason: "Tap should work");

    // Reset
    tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SInkButton(
            scaleFactor: 0.5, // Distinct scale factor
            child: Container(color: Colors.red, width: 100, height: 100),
            onTap: (_) {
              tapped = true;
            },
            onLongPressStart: (_) {
              longPressStarted = true;
            },
          ),
        ),
      ),
    ));

    // Press down
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(SInkButton)));
    await tester.pump(); // Process the down event
    await tester.pump(const Duration(milliseconds: 100)); // Wait a bit

    // Check if widget rebuilt with new scale target
    expect(_getScale(tester), 0.5,
        reason: "Target scale should be 0.5 after press");

    // Wait for long press to trigger (default is 500ms)
    // We need to pump frames to advance time
    await tester.pump(const Duration(milliseconds: 600));

    expect(longPressStarted, true, reason: "Long press should have started");

    // At this point, if the bug exists, the button might have popped up.
    // This means _isPressed became false, so target scale became 1.0.

    expect(_getScale(tester), 0.5,
        reason:
            "Button should remain scaled down (target scale 0.5) during long press");

    // Release
    await gesture.up();
    await tester.pump();

    expect(_getScale(tester), 1.0);
  });
}

double _getScale(WidgetTester tester) {
  final animatedScale =
      tester.widget<AnimatedScale>(find.byType(AnimatedScale));
  return animatedScale.scale;
}
