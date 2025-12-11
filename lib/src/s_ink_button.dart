import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

import 'haptic_feedback_type.dart';

class SInkButton extends StatefulWidget {
  final Widget child;
  final Color? color; // splash and hover color
  final String? tooltipMessage;

  final BorderRadius? hoverAndSplashBorderRadius;
  final double scaleFactor;
  final double initialSplashRadius; // Initial radius for splash animation
  final bool isActive, enableHapticFeedback, isCircleButton;
  final HapticFeedbackType? hapticFeedbackType;
  final void Function(Offset)? onTap;
  final void Function(Offset)? onDoubleTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;

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
  });

  @override
  State<SInkButton> createState() => _SInkButtonState();
}

class _SInkButtonState extends State<SInkButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  Offset? _tapPosition;
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
    _startSplashAnimation(details.globalPosition);
  }

  void _startSplashAnimation(Offset globalPosition, {double startValue = 0.0}) {
    // Only start animation if not already started to prevent conflicts
    if (_tapPosition == null || !_isPressed) {
      setState(() {
        _tapPosition = globalPosition;
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

  void _handleTapCancel() {
    if (!widget.isActive) return;

    _isPressed = false;

    // Trigger reverse animation
    setState(() {
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
        behavior: HitTestBehavior.translucent,
        onTapDown: widget.isActive ? _handleTapDown : null,
        onDoubleTapDown: widget.isActive && widget.onDoubleTap != null
            ? (details) {
                if (!widget.isActive) return;
                // log("_onDoubleTapDown called at: ${details.globalPosition}");
                // Use same animation behavior as regular tap for consistency
                if (_tapPosition == null || !_isPressed) {
                  _startSplashAnimation(details.globalPosition,
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
        onLongPressStart: widget.isActive && widget.onLongPressStart != null
            ? (details) {
                if (!widget.isActive) return;
                // Don't restart animation if it's already running from onTapDown
                // _startSplashAnimation(details.globalPosition, startValue: 0.02);
                widget.onLongPressStart!(details);
                if (widget.enableHapticFeedback) {
                  _triggerHapticFeedback(widget.hapticFeedbackType);
                }
              }
            : null,
        onLongPressEnd: widget.isActive && widget.onLongPressEnd != null
            ? (details) {
                if (!widget.isActive) return;
                // Trigger reverse animation
                setState(() {
                  _isAnimationReversing = true;
                });
                widget.onLongPressEnd!(details);
                if (widget.enableHapticFeedback) {
                  _triggerHapticFeedback(widget.hapticFeedbackType);
                }
              }
            : null,
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
                          if (_tapPosition != null) _buildSplashOverlay(),
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

  Widget _buildSplashOverlay() {
    return Positioned.fill(
      child: Builder(builder: (context) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return const SizedBox.shrink();

        final size = renderBox.size;
        if (size.width <= 0 || size.height <= 0) return const SizedBox.shrink();

        final localTapPosition = renderBox.globalToLocal(_tapPosition!);

        if (!_isTapPositionValid(localTapPosition, size)) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          child: STweenAnimationBuilder<double>(
            key: ValueKey('splash_$_splashKey$_isAnimationReversing'),
            tween: Tween<double>(
                begin: 0.0, end: _isAnimationReversing ? 0.0 : 1.0),
            duration: const Duration(milliseconds: 800),
            curve: _isAnimationReversing
                ? Curves.easeInCubic
                : Curves.easeOutCubic,
            onEnd: () {
              if (_isAnimationReversing && mounted) {
                setState(() {
                  _tapPosition = null;
                  _isPressed = false;
                  _isAnimationReversing = false;
                });
              } else if (!_isPressed && mounted) {
                // Auto-reverse when animation completes and not pressed
                setState(() {
                  _isAnimationReversing = true;
                });
              }
            },
            builder: (context, animValue, child) {
              final maxRadius = _calculateMaxRadius(size, localTapPosition);
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
                  center: localTapPosition,
                  radius: animatedRadius,
                  color: _splashColor.withValues(alpha: 0.12 * currentOpacity),
                ),
              );
            },
          ),
        );
      }),
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
