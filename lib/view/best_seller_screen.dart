import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzo/view/product_details/product_details_screen.dart';
import 'package:shopzo/view/top_picks/top_product_card.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../viewmodel/best_seller_viewmodel.dart';


class BestSellerScreen extends StatefulWidget {
  const BestSellerScreen({super.key});

  @override
  State<BestSellerScreen> createState() => _BestSellerScreenState();
}

class _BestSellerScreenState extends State<BestSellerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BestSellerViewModel>().fetchBestSellers();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const TextContext(text: 'Best Sellers', fontSize: 18, fontWeight: FontWeight.w600),
        centerTitle: true,
      ),
      body: Consumer<BestSellerViewModel>(
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
                    TextContext(text: vm.errorMessage ?? 'Something went wrong', fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor, textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    TextButton(onPressed: () => vm.fetchBestSellers(), child: const TextContext(text: 'Retry', fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstant.primaryColor)),
                  ],
                ),
              ),
            );
          }

          if (vm.isEmpty) {
            return const Center(
              child: TextContext(text: 'No best sellers right now', fontSize: 14, fontWeight: FontWeight.w500, color: ColorConstant.labelTextColor),
            );
          }

          return RefreshIndicator(
            color: ColorConstant.primaryColor,
            onRefresh: () => vm.fetchBestSellers(showLoader: false),
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
                  badgeLabel: "#${index + 1} Best Seller",
                  badgeIcon: Icons.local_fire_department_rounded,
                  badgeColor: ColorConstant.orangeColor,
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