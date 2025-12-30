## [1.1.0]

- HitTestBehavior? hitTestBehavior parameter added to determine whether the button responds to touch events and how it interacts with other widgets in the hit test hierarchy.


## [1.0.8]

- Fixed critical bug: When `onLongPressStart` callback was provided (non-null), the button would immediately pop back to its original scale when long press was detected. This was caused by a race condition in `GestureDetector`'s gesture arena resolution where `onTapCancel` would fire before the long press state was properly set. The fix ensures `_isLongPressing` and `_isPressed` are set synchronously before `setState` to prevent the cancellation from resetting the visual state.

## [1.0.7]

- Fixed bug: `onLongPressStart` and `onLongPressEnd` callbacks were overriding internal state management, causing the button to lose its pressed state (scale/splash) when these callbacks were provided. Now, internal logic always runs first to ensure consistent visual feedback.

## [1.0.6]

- Fixed visual bug where the button would momentarily pop back to its original scale when a long press gesture was detected. The button now correctly maintains its pressed state throughout the gesture transition.

## [1.0.5]

- Fixed issue: Handling gesture cancellations correctly when overlays like SnackBars appear, ensuring the long-press state explicitly overrides the cancellation and resets the animation state: in other words, the button now correctly maintains its pressed state (splash and scale) when a SnackBar is shown during a long press. 

## [1.0.4]

- updated README

## [1.0.3]

- updated README

## [1.0.2]

- updated README

## [1.0.1]

- updated README
- updated Documentation and Dart files convention

## [1.0.0] - 2025-12-11

- Initial release of s_ink_button
- Features: lightweight splash/hover animation without the need for a Material widget around the child, configurable splash color and radius, haptic feedback support, long press and double tap events, circle button support, and improved performance compared to InkWell for some layouts.
- Added example Flutter app with basic and advanced examples in `example/`
- Added widget tests in `test/` that validate tap, double tap and long-press handlers
- Included example screenshot asset and updated `README.md` with install and usage examples
- Added MIT license and `.pubignore`/.gitattributes to prepare for publishing
