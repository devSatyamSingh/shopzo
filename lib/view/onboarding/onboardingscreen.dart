import 'package:flutter/material.dart';
import '../../res/button_context.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../routes/route_name.dart';
import '../../utils/app_storage.dart';
import '../auth/login_screen.dart';

enum OnboardingBgShape { blob, circle, none }

class OnboardingData {
  final String image;
  final String title;
  final String description;
  final OnboardingBgShape bgShape;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    this.bgShape = OnboardingBgShape.blob,
  });
}

/// ---------------- ONBOARDING SCREEN ----------------
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      image: 'assets/images/onboarding1.png',
      title: 'Discover Amazing Products',
      description:
      'Explore thousands of products from top-rated vendors at your fingertips.',
      bgShape: OnboardingBgShape.blob,
    ),
    OnboardingData(
      image: 'assets/images/onboarding2.png',
      title: 'Secure & Easy Payments',
      description:
      'Your security is our priority. Enjoy multiple safe payment options for a worry-free shop.',
      bgShape: OnboardingBgShape.blob,
    ),
    OnboardingData(
      image: 'assets/images/onboarding3.png',
      title: 'Fast & Reliable Delivery',
      description:
      'Track your orders in real-time and get them delivered to your doorstep swiftly.',
      bgShape: OnboardingBgShape.circle,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // up-down floating animation for the illustration
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage == _pages.length - 1) {
      _onGetStarted();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() {
    _pageController.jumpToPage(_pages.length - 1);
  }

  Future<void> _onGetStarted() async {
    // Mark onboarding as seen FIRST — so if Splash ever runs again
    // (app restart, hot restart, etc.) it goes straight to Login instead
    // of showing these 3 pages again.
    await AppStorage.setOnboardingSeen();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteName.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.03),

            // ---------------- APP LOGO ----------------
            Container(
              height: size.width * 0.19,
              width: size.width * 0.19,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/shopzolo.png',
                fit: BoxFit.contain,
              ),
            ),

            // ---------------- PAGEVIEW ----------------
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _pages[index],
                    floatAnimation: _floatAnimation,
                  );
                },
              ),
            ),

            // ---------------- DOTS INDICATOR ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? ColorConstant.primaryColor
                        : ColorConstant.borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.025),

            // ---------------- BOTTOM CONTROLS ----------------
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02,
              ),
              child: isLastPage
                  ? CustomButton(
                text: 'Get Started',
                onTap: _onGetStarted,
                color: ColorConstant.primaryColor,
                icon: Icons.arrow_forward,
                iconColor: ColorConstant.whiteColor,
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _onSkip,
                    child: TextContext(
                      text: 'Skip',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.labelTextColor,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.4,
                    child: CustomButton(
                      text: 'Next',
                      onTap: _onNext,
                      color: ColorConstant.primaryColor,
                      icon: Icons.arrow_forward,
                      iconColor: ColorConstant.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SINGLE PAGE ----------------
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> floatAnimation;

  const _OnboardingPage({
    required this.data,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.03),

          // ---------------- IMAGE + DECORATIVE BACKGROUND ----------------
          SizedBox(
            height: size.height * 0.32,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ---- background shape (behind the image) ----
                if (data.bgShape == OnboardingBgShape.blob)
                  Container(
                    height: size.height * 0.34,
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryLight.withAlpha(180),
                      borderRadius: BorderRadius.circular(size.width * 0.14),
                    ),
                  )
                else if (data.bgShape == OnboardingBgShape.circle)
                  Container(
                    height: size.width * 1,
                    width: size.width * 1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorConstant.primaryLight,
                    ),
                  ),

                // ---- floating illustration (on top of the shape) ----
                AnimatedBuilder(
                  animation: floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    height: data.bgShape == OnboardingBgShape.circle
                        ? size.height * 0.18
                        : size.height * 0.22,
                    width: data.bgShape == OnboardingBgShape.circle
                        ? size.width * 0.54
                        : size.width * 0.72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstant.blackColor.withOpacity(.06),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.070),

          // ---------------- TITLE ----------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: TextContext(
              text: data.title,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              color: ColorConstant.headlineTextColor,
            ),
          ),

          SizedBox(height: size.height * 0.015),

          // ---------------- DESCRIPTION ----------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: TextContext(
              text: data.description,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              height: 1.5,
              color: ColorConstant.labelTextColor,
            ),
          ),
        ],
      ),
    );
  }
}