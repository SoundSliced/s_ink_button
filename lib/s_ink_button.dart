/// A Flutter package providing a customizable ink splash button with haptic feedback.
///
/// This library exports [SInkButton], a button widget that provides smooth ink splash
/// animations originating from the tap position, along with optional haptic feedback
/// and hover effects.
///
/// ## Features
/// - Ink splash animation from tap position
/// - Configurable haptic feedback
/// - Hover effects for desktop/web
/// - Scale animation on press
/// - Support for single tap, double tap, and long press gestures
///
/// ## Example
/// ```dart
/// SInkButton(
///   onTap: (position) => print('Tapped at $position'),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Press me'),
///   ),
/// )
/// ```
library;

export 'src/s_ink_button.dart';
export 'src/haptic_feedback_type.dart';
