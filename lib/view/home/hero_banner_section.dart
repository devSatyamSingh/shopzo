import 'dart:async';
import 'package:flutter/material.dart';
import '../../../res/button_context.dart';
import '../../../res/color_constant.dart';

class HeroBannerData {
  final String image;
  final String title;
  final String subtitle;

  const HeroBannerData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class HeroBannerSection extends StatefulWidget {
  final List<HeroBannerData> banners;
  final ValueChanged<int>? onShopNowTap;

  const HeroBannerSection({
    super.key,
    this.banners = const [
      HeroBannerData(
        image: 'assets/images/banner1.jpg',
        title: 'Upgrade Your Tech Style',
        subtitle: 'Up to 40% Off on Premium Audios',
      ),
      HeroBannerData(
        image: 'assets/images/banner2.jpg',
        title: 'Fresh Fits, New Season',
        subtitle: 'Flat 30% Off on Apparel',
      ),
      HeroBannerData(
        image: 'assets/images/banner3.jpg',
        title: 'Upgrade Your Space',
        subtitle: 'Up to 50% Off Home Essentials',
      ),
    ],
    this.onShopNowTap,
  });

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || widget.banners.isEmpty) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bannerHeight = size.height * 0.185;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        banner.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(gradient: ColorConstant.primaryGradient),
                        ),
                      ),
                      // gradient scrim so text stays readable on any image
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorConstant.blackColor.withOpacity(.55),
                              ColorConstant.blackColor.withOpacity(.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0, 0.75],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width * 0.55,
                              child: Text(
                                banner.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: size.width * 0.55,
                              child: Text(
                                banner.subtitle,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(.9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: size.width * 0.32,
                              height: 36,
                              child: CustomButton(
                                text: 'Shop Now',
                                onTap: () => widget.onShopNowTap?.call(index),
                                color: ColorConstant.whiteColor,
                                textColor: ColorConstant.headlineTextColor,
                                fontSize: 13,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: size.height * 0.012),

        // ---------------- DOTS ----------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentPage == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? ColorConstant.primaryColor
                    : ColorConstant.borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}  