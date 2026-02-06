import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../core/theme/color_scheme.dart';

enum AnimationType {
  fadeIn,
  fadeInUp,
  fadeInDown,
  fadeInLeft,
  fadeInRight,
  zoomIn,
  bounceIn,
  slideInUp,
  slideInDown,
  slideInLeft,
  slideInRight,
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final AnimationType animationType;
  final Duration duration;
  final Duration delay;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final bool enableHover;
  final double hoverElevation;

  const AnimatedCard({
    super.key,
    required this.child,
    this.animationType = AnimationType.fadeInUp,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius = 16,
    this.boxShadow,
    this.border,
    this.enableHover = true,
    this.hoverElevation = 8,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return _wrapWithAnimation(
      child: MouseRegion(
        onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
        onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: widget.margin,
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.border ?? Border.all(color: AppColors.border),
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? widget.hoverElevation * 2 : 10,
                      offset: Offset(0, _isHovered ? widget.hoverElevation : 4),
                    ),
                  ],
            ),
            transform: _isHovered && widget.enableHover
                ? (Matrix4.identity()..translate(0.0, -2.0))
                : Matrix4.identity(),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _wrapWithAnimation({required Widget child}) {
    switch (widget.animationType) {
      case AnimationType.fadeIn:
        return FadeIn(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.fadeInUp:
        return FadeInUp(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.fadeInDown:
        return FadeInDown(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.fadeInLeft:
        return FadeInLeft(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.fadeInRight:
        return FadeInRight(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.zoomIn:
        return ZoomIn(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.bounceIn:
        return BounceInDown(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.slideInUp:
        return SlideInUp(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.slideInDown:
        return SlideInDown(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.slideInLeft:
        return SlideInLeft(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
      case AnimationType.slideInRight:
        return SlideInRight(
          duration: widget.duration,
          delay: widget.delay,
          child: child,
        );
    }
  }
}
