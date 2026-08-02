import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.margin = EdgeInsets.zero,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.border,
    this.duration = const Duration(milliseconds: 180),
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final Duration duration;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _canHover {
    return !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  }

  void _setHover(bool value) {
    if (!_canHover) return;
    setState(() {
      _hovering = value;
    });
  }

  void _setPressed(bool value) {
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.985 : (_hovering ? 1.01 : 1.0);
    final alpha = (_hovering ? 0.18 : 0.12) * 255;
    final shadow = [
      BoxShadow(
        color: Colors.black.withAlpha(alpha.round()),
        blurRadius: _hovering ? 24 : 16,
        offset: const Offset(0, 10),
      ),
    ];

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        margin: widget.margin,
        transform: Matrix4.diagonal3Values(scale, scale, 1),
        decoration: BoxDecoration(
          color: widget.color ?? Colors.white,
          borderRadius: widget.borderRadius,
          border: widget.border,
          boxShadow: widget.border == null ? shadow : shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            splashColor: Colors.black12,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
