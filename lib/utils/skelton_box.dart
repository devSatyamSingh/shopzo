import 'package:flutter/material.dart';
import '../res/color_constant.dart';

/// Shopzo — reusable pulsing skeleton placeholder.
/// Used anywhere content is loading from an API (category icons,
/// subcategory grid, product grids, etc.) instead of a spinner.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: ColorConstant.fieldFillColor,
              shape: widget.shape,
              borderRadius:
              widget.shape == BoxShape.circle ? null : (widget.borderRadius ?? BorderRadius.circular(10)),
            ),
          ),
        );
      },
    );
  }
}