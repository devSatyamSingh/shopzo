// lib/view/home/top_picks_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/model/top_product_model.dart';
import 'package:shopzo/view/top_picks/top_picks_card.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import '../../localization/language_provider.dart';
import '../../viewmodel/top_pick_viewmodel.dart';
import 'top_picks_screen.dart';

class TopPicksSection extends StatefulWidget {
  final ValueChanged<TopProductModel>? onProductTap;
  final VoidCallback? onSeeAllTap;

  const TopPicksSection({
    super.key,
    this.onProductTap,
    this.onSeeAllTap,
  });

  @override
  State<TopPicksSection> createState() => _TopPicksSectionState();
}

class _TopPicksSectionState extends State<TopPicksSection> {
  @override
  void initState() {
    super.initState();
    // Home section apna khud ka fetch call karta hai — bilkul TopPicksScreen
    // jaisa hi (dono ab SAME TopPicksViewModel consume karte hain), isliye
    // dono jagah data ya empty-state EK HI source of truth se aayega.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TopPicksViewModel>();
      if (vm.products.isEmpty) {
        vm.fetchTopPicks();
      }
    });
  }

  void _navigateToTopPicksScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopPicksScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    context.watch<LanguageProvider>();

    return Consumer<TopPicksViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.products.isEmpty) {
          return const SizedBox.shrink();
        }
        if (vm.products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                children: [
                  TextContext(
                    text: 'top_picks.title'.tr(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.headlineTextColor,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onSeeAllTap ?? () => _navigateToTopPicksScreen(context),
                    child: TextContext(
                      text: 'flash_deals.see_all'.tr(),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.015),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: size.width * 0.04,
                right: size.width * 0.04,
                bottom: 12,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < vm.products.length.clamp(0, 6); i++) ...[
                    if (i != 0) SizedBox(width: size.width * 0.03),
                    TopPickCard(
                      product: vm.products[i],
                      width: size.width * 0.4,
                      onTap: () => widget.onProductTap?.call(vm.products[i]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}