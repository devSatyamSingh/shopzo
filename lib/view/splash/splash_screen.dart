import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../res/color_constant.dart';
import '../../routes/route_name.dart';

/// Shopzo — Splash Screen
/// Logo entrance animation + "Shop" (primary) / "zo" (orange) RichText
/// + pulsing loading dots. Fully responsive via MediaQuery.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _bounceController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _logoFade = CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn));

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _logoController.forward();
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;
    // TODO: check auth token here and route to RouteName.login OR RouteName.home
    Navigator.of(context).pushReplacementNamed(RouteName.onboarding);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final isLandscape = size.width > size.height;

    final double logoSize = (shortestSide * 0.25).clamp(70.0, 180.0);
    final double titleFontSize = (size.width * 0.1).clamp(25.0, 50.0);
    final double taglineFontSize = (size.width * 0.032).clamp(11.0, 16.0);
    final double spacing = size.height * 0.023;

    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: Listenable.merge([_logoController, _bounceController]),
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoFade.value,
                              child: Transform.translate(
                                offset: Offset(0, _bounce.value),
                                child: Transform.scale(scale: _logoScale.value, child: child),
                              ),
                            );
                          },
                          child: _ShopzoLogo(size: logoSize),
                        ),
                        SizedBox(height: spacing),
                        FadeTransition(
                          opacity: _textFade,
                          child: SlideTransition(
                            position: _textSlide,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  height: 1.0,
                                ),
                                children: [
                                  TextSpan(text: 'Shop', style: GoogleFonts.poppins(color: ColorConstant.primaryColor, fontSize: 32)),
                                  TextSpan(text: 'zo', style: GoogleFonts.poppins(color: ColorConstant.orangeColor,  fontSize: 32)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing * 0.4),
                        FadeTransition(
                          opacity: _textFade,
                          child: Text(
                            'Shop Smart. Shop Fast.',
                            style: GoogleFonts.poppins(
                              fontSize: taglineFontSize,
                              color: ColorConstant.labelTextColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: isLandscape ? constraints.maxHeight * 0.08 : constraints.maxHeight * 0.06,
                  left: 0,
                  right: 0,
                  child: const _LoadingDots(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShopzoLogo extends StatelessWidget {
  final double size;
  const _ShopzoLogo({required this.size});

  static const String assetPath = 'assets/images/shopzolo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.18),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.primaryColor.withOpacity(0.2),
            blurRadius: size * 0.08,
            offset: Offset(0, size * 0.02),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.24),
            gradient: ColorConstant.brandGradient,
          ),
          child: Icon(Icons.shopping_bag_rounded, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dotSize = (MediaQuery.of(context).size.width * 0.022).clamp(6.0, 10.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final double delay = index * 0.2;
            double t = (_controller.value - delay) % 1.0;
            if (t < 0) t += 1.0;
            final double bounce = (t < 0.5) ? (t * 2) : (1 - (t - 0.5) * 2);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dotSize * 0.5),
              child: Opacity(
                opacity: 0.35 + (bounce * 0.65),
                child: Transform.scale(
                  scale: 0.7 + (bounce * 0.5),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: ColorConstant.primaryColor),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
