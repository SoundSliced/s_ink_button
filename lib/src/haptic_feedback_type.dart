/// Defines the type of haptic feedback to trigger when the button is tapped.
///
/// Each type corresponds to a different intensity or pattern of haptic feedback
/// provided by the device's haptic engine.
///
/// ## Example
/// ```dart
/// SInkButton(
///   hapticFeedbackType: HapticFeedbackType.mediumImpact,
///   onTap: (_) => print('Tapped!'),
///   child: Text('Button'),
/// )
/// ```
enum HapticFeedbackType {
  /// A light impact haptic feedback.
  ///
  /// Provides a subtle tap sensation, suitable for minor interactions.
  lightImpact,

  /// A medium impact haptic feedback.
  ///
  /// Provides a moderate tap sensation, suitable for standard button presses.
  mediumImpact,

  /// A heavy impact haptic feedback.
  ///
  /// Provides a strong tap sensation, suitable for significant actions.
  heavyImpact,

  /// A selection click haptic feedback.
  ///
  /// Provides feedback similar to picking an item from a list or picker.
  selectionClick,

  /// A vibration haptic feedback.
  ///
  /// Provides a longer vibration pattern, suitable for alerts or errors.
  vibrate,
}
