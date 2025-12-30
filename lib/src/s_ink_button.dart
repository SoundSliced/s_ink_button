import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

import 'haptic_feedback_type.dart';

/// A customizable button widget with ink splash animation and haptic feedback.
///
/// [SInkButton] provides a Material Design-inspired ink splash effect that
/// originates from the exact tap position, creating a more natural and
/// responsive feel compared to standard buttons.
///
/// ## Features
/// - **Ink splash animation**: Circular splash effect expanding from tap position
/// - **Haptic feedback**: Optional tactile feedback on tap (iOS/Android)
/// - **Hover effects**: Visual feedback on mouse hover (desktop/web)
/// - **Scale animation**: Subtle press-down effect
/// - **Multiple gestures**: Support for tap, double-tap, and long-press
/// - **Customizable appearance**: Configurable colors, border radius, and more
///
/// ## Basic Example
/// ```dart
/// SInkButton(
///   onTap: (position) {
///     print('Button tapped at $position');
///   },
///   child: Container(
///     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
///     decoration: BoxDecoration(
///       color: Colors.blue,
///       borderRadius: BorderRadius.circular(8),
///     ),
///     child: Text('Press Me', style: TextStyle(color: Colors.white)),
///   ),
/// )
/// ```
///
/// ## Advanced Example with Custom Settings
/// ```dart
/// SInkButton(
///   color: Colors.purple,
///   scaleFactor: 0.95,
///   hoverAndSplashBorderRadius: BorderRadius.circular(16),
///   hapticFeedbackType: HapticFeedbackType.mediumImpact,
///   onTap: (position) => handleTap(),
///   onLongPressStart: (details) => showMenu(),
///   tooltipMessage: 'Long press for options',
///   child: MyCustomButton(),
/// )
/// ```
///
/// See also:
/// - [HapticFeedbackType] for available haptic feedback options
class SInkButton extends StatefulWidget {
  /// Creates an [SInkButton] with the given child widget.
  ///
  /// The [child] parameter is required and represents the content of the button.
  const SInkButton({
    super.key,
    required this.child,
    this.color,
    this.hoverAndSplashBorderRadius,
    this.scaleFactor = 0.985,
    this.initialSplashRadius = 0.5,
    this.isActive = true,
    this.enableHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.lightImpact,
    this.onTap,
    this.onDoubleTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.isCircleButton = false,
    this.tooltipMessage,
    this.hitTestBehavior,
  });

  /// The widget displayed inside the button.
  ///
  /// This is typically a [Container], [Text], [Icon], or any other widget
  /// that represents the button's content.
  final Widget child;

  /// The color used for the splash and hover effects.
  ///
  /// If null, defaults to [Colors.purple].
  ///
  /// The splash effect uses this color with reduced opacity (12%),
  /// and the hover effect uses a darkened version with 4% opacity.
  final Color? color;

  /// Optional tooltip message displayed when hovering over the button.
  ///
  /// When [isActive] is false, the tooltip displays "Button is disabled".
  final String? tooltipMessage;

  /// The border radius applied to the hover and splash effects.
  ///
  /// If null, defaults to `BorderRadius.circular(8)` for rectangular buttons
  /// or `BorderRadius.circular(40)` for circle buttons.
  final BorderRadius? hoverAndSplashBorderRadius;

  /// The scale factor applied when the button is pressed.
  ///
  /// Values less than 1.0 shrink the button on press.
  /// Defaults to 0.985 for a subtle press effect.
  ///
  /// Set to 1.0 to disable the scale animation.
  final double scaleFactor;

  /// The initial radius of the splash animation.
  ///
  /// Controls how large the splash circle is at the start of the animation.
  /// Defaults to 0.5 pixels.
  final double initialSplashRadius;

  /// Whether the button responds to user interactions.
  ///
  /// When false, the button ignores all gestures and displays
  /// a "Button is disabled" tooltip.
  final bool isActive;

  /// Whether to trigger haptic feedback on tap.
  ///
  /// Defaults to true. Set to false to disable haptic feedback.
  final bool enableHapticFeedback;

  /// Whether the button has a circular shape.
  ///
  /// When true, uses circular clipping for the splash effect.
  /// Defaults to false.
  final bool isCircleButton;

  /// The type of haptic feedback to trigger on tap.
  ///
  /// Defaults to [HapticFeedbackType.lightImpact].
  /// Set to null to disable haptic feedback regardless of [enableHapticFeedback].
  final HapticFeedbackType? hapticFeedbackType;

  /// Callback invoked when the button is tapped.
  ///
  /// The [Offset] parameter contains the global position of the tap.
  final void Function(Offset)? onTap;

  /// Callback invoked when the button is double-tapped.
  ///
  /// The [Offset] parameter contains the global position of the tap.
  final void Function(Offset)? onDoubleTap;

  /// Callback invoked when a long press gesture starts.
  ///
  /// Useful for showing context menus or additional options.
  final void Function(LongPressStartDetails)? onLongPressStart;

  /// Callback invoked when a long press gesture ends.
  final void Function(LongPressEndDetails)? onLongPressEnd;

  /// The behavior of the button when it comes to hit testing.
  ///
  /// This determines whether the button responds to touch events
  /// and how it interacts with other widgets in the hit test
  /// hierarchy.
  final HitTestBehavior? hitTestBehavior;

  @override
  State<SInkButton> createState() => _SInkButtonState();
}

class _SInkButtonState extends State<SInkButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isLongPressing = false; // Track long press state separately
  Offset? _tapPosition;
  Offset? _localTapPosition;
  int _splashKey = 0; // Increment to trigger new animation
  bool _isAnimationReversing = false;

  late Color _splashColor;

  @override
  void initState() {
    super.initState();
    _cacheComputedValues();
  }

  void _cacheComputedValues() {
    _splashColor = widget.color ?? Colors.purple;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isActive) return;
    // log("_handleTapDown called at: ${details.globalPosition}");
    _startSplashAnimation(details.globalPosition, details.localPosition);
  }

  void _startSplashAnimation(Offset globalPosition, Offset localPosition,
      {double startValue = 0.0}) {
    // Only start animation if not already started to prevent conflicts
    if (_tapPosition == null || !_isPressed) {
      setState(() {
        _tapPosition = globalPosition;
        _localTapPosition = localPosition;
        _isPressed = true;
        _isAnimationReversing = false;
        _splashKey++; // Trigger new animation
      });
    } else {
      // Animation already started, just update position if different
      if ((_tapPosition! - globalPosition).distance > 5.0) {
        // Only update if significantly different
        setState(() {
          _tapPosition = globalPosition;
          _localTapPosition = localPosition;
        });
      }
    }
  }

  double _calculateMaxRadius(Size size, Offset tapPosition) {
    // Don't cache by size alone - radius depends on tap position too
    // Calculate fresh every time to ensure accuracy for different tap positions

    final w = size.width;
    final h = size.height;
    final dx = tapPosition.dx.clamp(0.0, w);
    final dy = tapPosition.dy.clamp(0.0, h);

    // Calculate distances to all corners to find the maximum
    double maxDistance = 0.0;
    final distances = <double>[
      _distance(dx, dy, 0, 0), // top-left
      _distance(dx, dy, w, 0), // top-right
      _distance(dx, dy, 0, h), // bottom-left
      _distance(dx, dy, w, h), // bottom-right
    ];

    for (final distance in distances) {
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    return maxDistance;
  }

  @pragma('vm:prefer-inline')
  double _distance(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return math.sqrt(dx * dx + dy * dy);
  }

  void _handleTapUp() {
    if (!widget.isActive) return;

    _isPressed = false;

    if (widget.enableHapticFeedback) {
      _triggerHapticFeedback(widget.hapticFeedbackType);
    }
    widget.onTap?.call(_tapPosition ?? Offset.zero);

    // Trigger reverse animation
    setState(() {
      _isAnimationReversing = true;
    });
  }

  void _triggerHapticFeedback(HapticFeedbackType? type) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
      case null:
        break;
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!widget.isActive) return;

    // CRITICAL: Set _isLongPressing synchronously BEFORE setState
    // This ensures that when _handleTapCancel's microtask checks this flag,
    // it's already true. If we set it inside setState, the microtask may
    // run before the setState callback completes.
    _isLongPressing = true;
    _isPressed = true;

    setState(() {
      _isAnimationReversing = false;
    });

    widget.onLongPressStart?.call(details);

    if (widget.enableHapticFeedback) {
      _triggerHapticFeedback(widget.hapticFeedbackType);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!widget.isActive) return;

    _isLongPressing = false;
    _isPressed = false;

    setState(() {
      _isAnimationReversing = true;
    });

    widget.onLongPressEnd?.call(details);

    if (widget.enableHapticFeedback) {
      _triggerHapticFeedback(widget.hapticFeedbackType);
    }
  }

  void _handleTapCancel() {
    if (!widget.isActive) return;

    // The cancel might be because long press won.
    // We delay the cancel handling to allow onLongPressStart to fire first.
    Future.microtask(() {
      if (mounted && !_isLongPressing) {
        _performCancel();
      }
    });
  }

  void _performCancel() {
    // Don't cancel the splash/scale animation if we're in a long press
    // This prevents SnackBars or other overlays from interrupting the long press visual feedback
    if (_isLongPressing) return;

    setState(() {
      _isPressed = false;
      _isAnimationReversing = true;
    });
  }

  @override
  void didUpdateWidget(covariant SInkButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update cached values when relevant properties change
    final shouldUpdateCache = oldWidget.child != widget.child ||
        oldWidget.hoverAndSplashBorderRadius !=
            widget.hoverAndSplashBorderRadius ||
        oldWidget.color != widget.color ||
        oldWidget.tooltipMessage != widget.tooltipMessage;

    if (shouldUpdateCache) {
      _cacheComputedValues();
    }

    // Only rebuild if properties that affect the widget tree have changed
    final needsRebuild = shouldUpdateCache ||
        oldWidget.isActive != widget.isActive ||
        oldWidget.scaleFactor != widget.scaleFactor ||
        oldWidget.child != widget.child;

    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  bool _isTapPositionValid(Offset tapPosition, Size childSize) {
    return tapPosition.dx >= 0 &&
        tapPosition.dx <= childSize.width &&
        tapPosition.dy >= 0 &&
        tapPosition.dy <= childSize.height;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter:
          widget.isActive ? (_) => setState(() => _isHovered = true) : null,
      onExit:
          widget.isActive ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        behavior: widget.hitTestBehavior ?? HitTestBehavior.translucent,
        onTapDown: widget.isActive ? _handleTapDown : null,
        onDoubleTapDown: widget.isActive && widget.onDoubleTap != null
            ? (details) {
                if (!widget.isActive) return;
                // log("_onDoubleTapDown called at: ${details.globalPosition}");
                // Use same animation behavior as regular tap for consistency
                if (_tapPosition == null || !_isPressed) {
                  _startSplashAnimation(
                      details.globalPosition, details.localPosition,
                      startValue: 0.0);
                }
              }
            : null,
        onDoubleTap: widget.isActive && widget.onDoubleTap != null
            ? () {
                if (!widget.isActive) return;
                widget.onDoubleTap!(_tapPosition ?? Offset.zero);
                if (widget.enableHapticFeedback) {
                  _triggerHapticFeedback(widget.hapticFeedbackType);
                }
              }
            : null,
        onLongPressStart: widget.isActive ? _handleLongPressStart : null,
        onLongPressEnd: widget.isActive ? _handleLongPressEnd : null,
        onTapUp: widget.isActive ? (_) => _handleTapUp() : null,
        onTapCancel: widget.isActive ? _handleTapCancel : null,
        child: AnimatedScale(
          scale: _isPressed ? widget.scaleFactor : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Child widget
              Tooltip(
                message: widget.isActive
                    ? widget.tooltipMessage ?? ""
                    : "Button is disabled",
                child: widget.child,
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: widget.hoverAndSplashBorderRadius ??
                        BorderRadius.circular(widget.isCircleButton ? 40 : 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: widget.isCircleButton
                            ? null
                            : widget.hoverAndSplashBorderRadius ??
                                BorderRadius.circular(8),
                        shape: widget.isCircleButton
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          // Base hover overlay
                          if (_isHovered)
                            IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: _splashColor
                                      .darken()
                                      .withValues(alpha: 0.04),
                                ),
                              ),
                            ),

                          // Splash overlay
                          if (_tapPosition != null)
                            Positioned.fill(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return _buildSplashOverlay(
                                      constraints.biggest);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplashOverlay(Size size) {
    if (_localTapPosition == null) return const SizedBox.shrink();

    if (!_isTapPositionValid(_localTapPosition!, size)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: STweenAnimationBuilder<double>(
        key: ValueKey('splash_$_splashKey$_isAnimationReversing'),
        tween:
            Tween<double>(begin: 0.0, end: _isAnimationReversing ? 0.0 : 1.0),
        duration: const Duration(milliseconds: 800),
        curve: _isAnimationReversing ? Curves.easeInCubic : Curves.easeOutCubic,
        onEnd: () {
          if (_isAnimationReversing && mounted) {
            setState(() {
              _tapPosition = null;
              _localTapPosition = null;
              _isPressed = false;
              _isAnimationReversing = false;
            });
          } else if (!_isPressed && !_isLongPressing && mounted) {
            // Auto-reverse when animation completes and not pressed and not in long press
            setState(() {
              _isAnimationReversing = true;
            });
          }
        },
        builder: (context, animValue, child) {
          final maxRadius = _calculateMaxRadius(size, _localTapPosition!);
          // Opacity: fade in during first 30%, stay at 1.0, fade out on reverse
          final currentOpacity = _isAnimationReversing
              ? animValue
              : (animValue < 0.3 ? 0.3 + (animValue / 0.3 * 0.7) : 1.0);

          // Calculate radius with configurable minimum starting value for better visual effect
          final minRadius = widget.initialSplashRadius;
          final animatedRadius =
              minRadius + (animValue * (maxRadius - minRadius));

          return CustomPaint(
            painter: _SplashPainter(
              center: _localTapPosition!,
              radius: animatedRadius,
              color: _splashColor.withValues(alpha: 0.12 * currentOpacity),
            ),
          );
        },
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  const _SplashPainter(
      {required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0.1) return;

    final effectiveRadius = radius.clamp(0.1, double.infinity);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(center, effectiveRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.center != center ||
        oldDelegate.color != color;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _SplashPainter &&
        other.center == center &&
        other.radius == radius &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(center, radius, color);
}
