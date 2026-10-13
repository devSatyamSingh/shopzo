import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/top_picks/top_product_card.dart';
import '../../localization/language_provider.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../../viewmodel/top_pick_viewmodel.dart';
import '../product_details/product_details_screen.dart';

class TopPicksScreen extends StatefulWidget {
  const TopPicksScreen({super.key});

  @override
  State<TopPicksScreen> createState() => _TopPicksScreenState();
}

class _TopPicksScreenState extends State<TopPicksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopPicksViewModel>().fetchTopPicks();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width - size.width * 0.05 * 2 - size.width * 0.04) / 2;

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ColorConstant.headlineTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextContext(
          text: 'top_picks.title'.tr(),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: Consumer<TopPicksViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.products.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: ColorConstant.primaryColor));
          }

          if (vm.hasError && vm.products.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 40, color: ColorConstant.placeholderColor),
                    const SizedBox(height: 10),
                TextContext(
                  text: vm.errorMessage ?? 'top_picks.something_wrong'.tr(),),
                  const SizedBox(height: 14),
                    TextButton(onPressed: () => vm.fetchTopPicks(), child: TextContext(text: 'top_picks.retry'.tr(), fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor)),
                  ],
                ),
              ),
            );
          }

          if (vm.isEmpty) {
            return Center(
              child: TextContext(text: 'top_picks.no_picks'.tr(), fontSize: 14, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor),
            );
          }

          return RefreshIndicator(
            color: ColorConstant.primaryColor,
            onRefresh: () => vm.fetchTopPicks(showLoader: false),
            child: GridView.builder(
              padding: EdgeInsets.all(size.width * 0.05),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: vm.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: size.height * 0.02,
                crossAxisSpacing: size.width * 0.04,
                childAspectRatio: cardWidth / (size.height * 0.30),
              ),
              itemBuilder: (context, index) {
                final product = vm.products[index];
                return TopProductCard(
                  product: product,
                  width: cardWidth,
                  badgeLabel: 'top_picks.badge'.tr(),
                  badgeIcon: Icons.trending_up_rounded,
                  badgeColor: ColorConstant.primaryColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id))),
                );
              },
            ),
          );
        },
      ),
    );
  }
}