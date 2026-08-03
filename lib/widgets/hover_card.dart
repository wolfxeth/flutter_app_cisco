import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Modern surface used across the app. Renders a rounded, softly-shadowed
/// container with a subtle border, a gentle hover lift on desktop, and a
/// press micro-interaction on all platforms.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.margin = EdgeInsets.zero,
    this.padding,
    this.borderRadius,
    this.border,
    this.showShadow = true,
    this.showBorder = true,
    this.gradient,
    this.duration = const Duration(milliseconds: 180),
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final bool showShadow;
  final bool showBorder;
  final Gradient? gradient;
  final Duration duration;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _canHover =>
      !(defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _setHover(bool value) {
    if (!_canHover) return;
    if (_hovering == value) return;
    setState(() => _hovering = value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusCard);
    final scale = _pressed ? 0.992 : (_hovering ? 1.006 : 1.0);

    BoxBorder? border = widget.border;
    if (border == null && widget.showBorder) {
      border = Border.all(
        color: _hovering
            ? AppTheme.primary.withValues(alpha: 0.35)
            : AppTheme.border,
        width: 1,
      );
    }

    List<BoxShadow>? shadow;
    if (widget.showShadow) {
      shadow = _hovering
          ? AppTheme.softShadow(blur: 28, y: 12)
          : AppTheme.softShadow(blur: 16, y: 6);
    }

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        margin: widget.margin,
        transform: Matrix4.diagonal3Values(scale, scale, 1),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.gradient == null
              ? (widget.color ?? Colors.white)
              : null,
          gradient: widget.gradient,
          borderRadius: radius,
          border: border,
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            splashColor: AppTheme.primary.withValues(alpha: 0.06),
            highlightColor: AppTheme.primary.withValues(alpha: 0.04),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(18),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
