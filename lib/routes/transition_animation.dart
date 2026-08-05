import 'package:flutter/material.dart';

/// Available transition types for navigation
enum TransitionType {
  fade,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  slideUp,
  scaleFade,
  zoomIn,
  rotation,
  sizeFade,
  custom,
}

/// Centralized transition animations
class TransitionAnimations {
  const TransitionAnimations._();

  /// Build the appropriate transition based on type
  static Widget buildTransition(
      TransitionType type,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    switch (type) {
      case TransitionType.fade:
        return _fadeTransition(animation, child);
      case TransitionType.slideFromRight:
        return _slideFromRight(animation, child);
      case TransitionType.slideFromLeft:
        return _slideFromLeft(animation, child);
      case TransitionType.slideFromBottom:
        return _slideFromBottom(animation, child);
      case TransitionType.slideFromTop:
        return _slideFromTop(animation, child);
      case TransitionType.slideUp:
        return _slideUp(animation, child);
      case TransitionType.scaleFade:
        return _scaleFade(animation, child);
      case TransitionType.zoomIn:
        return _zoomIn(animation, secondaryAnimation, child);
      case TransitionType.rotation:
        return _rotation(animation, child);
      case TransitionType.sizeFade:
        return _sizeFade(animation, child);
      case TransitionType.custom:
        return _customTransition(animation, child);
    }
  }

  // --- Individual Transition Builders ---

  /// Simple Fade transition
  static Widget _fadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Slide from right to left (like iOS push)
  static Widget _slideFromRight(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  /// Slide from left to right (like iOS pop)
  static Widget _slideFromLeft(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  /// Slide from bottom to top
  static Widget _slideFromBottom(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      )),
      child: child,
    );
  }

  /// Slide from top to bottom
  static Widget _slideFromTop(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      )),
      child: child,
    );
  }

  /// Slide up (for bottom sheets)
  static Widget _slideUp(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuint,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }

  /// Scale + Fade (modern material effect)
  static Widget _scaleFade(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.92,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }

  /// Zoom in effect
  static Widget _zoomIn(
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.6,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }

  /// Rotation transition
  static Widget _rotation(Animation<double> animation, Widget child) {
    return RotationTransition(
      turns: Tween<double>(
        begin: -0.05,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Size + Fade (like expanding)
  static Widget _sizeFade(Animation<double> animation, Widget child) {
    return SizeTransition(
      sizeFactor: Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }

  /// Custom transition with multiple effects
  static Widget _customTransition(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuint,
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}