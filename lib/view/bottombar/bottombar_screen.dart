import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}

/// Shopzo — animated notch bottom navigation bar.
/// The colored bar has a smooth scooped notch that slides to whichever
/// tab is selected, and that tab's icon floats above it inside a
/// white circle. Everything animates with a single AnimationController.
class AnimatedNotchBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  const AnimatedNotchBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  static List<BottomNavItem> items = [
    BottomNavItem(
      icon: Icons.home_rounded,
      label: 'bottom_nav.home',
    ),
    BottomNavItem(
      icon: Icons.grid_view_rounded,
      label: 'bottom_nav.categories',
    ),
    BottomNavItem(
      icon: Icons.shopping_bag_rounded,
      label: 'bottom_nav.cart',
    ),
    BottomNavItem(
      icon: Icons.receipt_long_rounded,
      label: 'bottom_nav.orders',
    ),
    BottomNavItem(
      icon: Icons.person_rounded,
      label: 'bottom_nav.profile',
    ),
  ];

  @override
  State<AnimatedNotchBottomNavBar> createState() =>
      _AnimatedNotchBottomNavBarState();
}

class _AnimatedNotchBottomNavBarState extends State<AnimatedNotchBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _positionAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _positionAnim = AlwaysStoppedAnimation(widget.currentIndex.toDouble());
  }

  @override
  void didUpdateWidget(covariant AnimatedNotchBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final start = _positionAnim.value;
      _positionAnim = Tween<double>(
        begin: start,
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final barHeight = size.height * 0.0;
    final rowHeight = size.height * 0.05;
    final circleSize = size.width * 0.120;
    final itemCount = AnimatedNotchBottomNavBar.items.length;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: ColorConstant.whiteColor,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final itemWidth = width / itemCount;
                final notchCenterX = itemWidth * _positionAnim.value + itemWidth / 2;
                final notchRadius = circleSize / 2 + 6;
      
                return SizedBox(
                  height: barHeight + rowHeight,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ---------------- COLORED BAR + NOTCH ----------------
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: CustomPaint(
                          size: Size(width, barHeight),
                          painter: _NotchPainter(
                            notchCenterX: notchCenterX,
                            notchRadius: notchRadius,
                            notchDepth: notchRadius * 1.05,
                            color: ColorConstant.whiteColor,
                          ),
                        ),
                      ),
      
                      // ---------------- ICON + LABEL ROW ----------------
                      Positioned(
                        top: barHeight,
                        left: 0,
                        right: 0,
                        height: rowHeight,
                        child: Row(
                          children: List.generate(itemCount, (index) {
                            final bool isSelected = index == widget.currentIndex;
                            final bool isCart = index == 2;
                            final item = AnimatedNotchBottomNavBar.items[index];
      
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => widget.onTap(index),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!isSelected)
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Icon(item.icon,
                                              size: 22,
                                              color: ColorConstant.headlineTextColor),
                                          if (isCart && widget.cartCount > 0)
                                            Positioned(
                                              top: -6,
                                              right: -9,
                                              child: _CartBadge(count: widget.cartCount),
                                            ),
                                        ],
                                      )
                                    else
                                      const SizedBox(height: 22),
                                    const SizedBox(height: 5),
                                    TextContext(
                                      text: item.label.tr(),
                                      fontSize: 11,
                                      fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected
                                          ? ColorConstant.primaryColor
                                          : ColorConstant.headlineTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
      
                      // ---------------- FLOATING SELECTED CIRCLE ----------------
                      Positioned(
                        top: barHeight - circleSize / 2,
                        left: notchCenterX - circleSize / 2,
                        child: GestureDetector(
                          onTap: () => widget.onTap(widget.currentIndex),
                          child: Container(
                            height: circleSize,
                            width: circleSize,
                            decoration: BoxDecoration(
                              color: ColorConstant.whiteColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorConstant.blackColor.withOpacity(.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  AnimatedNotchBottomNavBar
                                      .items[widget.currentIndex].icon,
                                  size: circleSize * 0.44,
                                  color: ColorConstant.primaryColor,
                                ),
                                if (widget.currentIndex == 2 && widget.cartCount > 0)
                                  Positioned(
                                    top: -2,
                                    right: circleSize * 0.12,
                                    child: _CartBadge(count: widget.cartCount),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final int count;
  const _CartBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16),
      decoration: BoxDecoration(
        color: ColorConstant.orangeColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstant.whiteColor, width: 1.4),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          height: 1.2,
        ),
      ),
    );
  }
}

/// Draws the colored bar as a rectangle with a smooth scooped notch
/// cut upward from the bottom edge, centered at [notchCenterX].
class _NotchPainter extends CustomPainter {
  final double notchCenterX;
  final double notchRadius;
  final double notchDepth;
  final Color color;

  _NotchPainter({
    required this.notchCenterX,
    required this.notchRadius,
    required this.notchDepth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    const double topRadius = 20;
    final double curveWidth = notchRadius * 1.7;
    final double left = notchCenterX - curveWidth;
    final double right = notchCenterX + curveWidth;

    path.moveTo(0, topRadius);
    path.quadraticBezierTo(0, 0, topRadius, 0);
    path.lineTo(size.width - topRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, topRadius);
    path.lineTo(size.width, size.height);
    path.lineTo(right, size.height);

    // scoop upward into the bar, centered on notchCenterX
    path.cubicTo(
      right - curveWidth * 0.55, size.height,
      notchCenterX + notchRadius, size.height - notchDepth * 0.92,
      notchCenterX, size.height - notchDepth,
    );
    path.cubicTo(
      notchCenterX - notchRadius, size.height - notchDepth * 0.92,
      left + curveWidth * 0.55, size.height,
      left, size.height,
    );

    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchPainter oldDelegate) {
    return oldDelegate.notchCenterX != notchCenterX ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.notchDepth != notchDepth ||
        oldDelegate.color != color;
  }
}