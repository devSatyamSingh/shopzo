import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../res/button_context.dart';
import '../../../res/color_constant.dart';
import '../../viewmodel/banner_viewmodel.dart';

class HeroBannerSection extends StatefulWidget {
  final ValueChanged<int>? onShopNowTap;

  const HeroBannerSection({super.key, this.onShopNowTap});

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;
  int _bannerCount = 0;

  void _startAutoScroll(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % count;
      if (_controller.hasClients) {
        _controller.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
      }
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
    final bannerHeight = size.height * 0.200;

    return Consumer<BannerViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return _buildSkeleton(size, bannerHeight);
        }

        if (vm.hasError) {
          return _buildErrorState(size, bannerHeight, vm);
        }

        if (vm.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = vm.banners;
        if (_bannerCount != banners.length) {
          _bannerCount = banners.length;
          WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll(_bannerCount));
        }

        return Column(
          children: [
            SizedBox(
              height: bannerHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: banners.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: GestureDetector(
                      onTap: (banner.linkUrl != null) ? () => widget.onShopNowTap?.call(index) : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(gradient: ColorConstant.primaryGradient),
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    height: 22, width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(gradient: ColorConstant.primaryGradient),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported_outlined, color: Colors.white70, size: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: size.height * 0.012),
            if (banners.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: _currentPage == index ? 18 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? ColorConstant.primaryColor : ColorConstant.borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton(Size size, double bannerHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: ColorConstant.fieldFillColor,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          height: 22, width: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorState(Size size, double bannerHeight, BannerViewModel vm) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: ColorConstant.fieldFillColor,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: ColorConstant.errorColor, size: 26),
            const SizedBox(height: 8),
            SizedBox(
              width: size.width * 0.4,
              height: 32,
              child: CustomButton(
                text: 'home.retry'.tr(),
                fontSize: 12,
                onTap: () => vm.fetchBanners(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}