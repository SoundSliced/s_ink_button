# s_ink_button


Lightweight and flexible ink splash button for Flutter that doesn't require being wrapped in a Material widget. Ideal for lightweight UI elements, with configurable appearance and built-in haptic feedback.

![Demo](https://raw.githubusercontent.com/SoundSliced/s_ink_button/main/example/assets/example.gif)

 
## Features

- Customizable splash color, radius, and animations
- Built-in haptic feedback support
- Hover overlay on desktop platforms
- Long-press and double-tap handlers
- Optional circle-shaped button variant
- High performance and easy to use

## Install

Add s_ink_button to your `pubspec.yaml`:

From pub.dev (recommended after publishing):

```yaml
dependencies:
  s_ink_button: ^1.1.0
```

Or from GitHub:

```yaml
dependencies:
  s_ink_button:
    git: https://github.com/SoundSliced/s_ink_button.git
```

For local testing within this repository, the example uses a path dependency to the package root.

## Basic example

```dart
SInkButton(
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.purple.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text('Tap me'),
  ),
  onTap: (pos) {
    // Handle tap
  },
),
```

## Advanced example

Use the `isCircleButton` option and add haptic feedback and other handlers:

```dart
SInkButton(
  child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.purple,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.favorite, color: Colors.white),
  ),
  isCircleButton: true,
  scaleFactor: 0.975,
  initialSplashRadius: 6,
  hapticFeedbackType: HapticFeedbackType.mediumImpact,
  color: Colors.red.withValues(alpha: 0.9),
  enableHapticFeedback: true,
  onDoubleTap: (pos) { /*...*/ },
  onLongPressStart: (d) { /*...*/ },
  onLongPressEnd: (d) { /*...*/ },
)
```

The example application is under the `example/` directory, showing both basic and advanced usage. The screenshot above is the example GIF from `example/assets`.

## Example assets

If you use the example's screenshot (example/assets/example.gif) in README, make sure to keep the GitHub path like:

`https://raw.githubusercontent.com/SoundSliced/s_ink_button/main/example/assets/example.gif`
  
Also view the complete example app in the repository: https://github.com/SoundSliced/s_ink_button/tree/main/example

## Tests

Basic widget tests are included in the `test/` folder. They verify callbacks for tap, double tap and long-press.

## License

MIT (see `LICENSE` file)

## Try it

To run the example application locally:

```bash
cd example
flutter pub get
flutter run
```

To run tests:

```bash
flutter test
```
