// lib/view/home/top_picks_screen.dart
import 'package:flutter/material.dart';
import 'package:shopzo/view/home/product_card.dart';
import 'package:shopzo/view/home/product_model.dart';
import '../../../../res/color_constant.dart';
import '../../../../res/text_context.dart';

class TopPicksScreen extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;

  const TopPicksScreen({
    super.key,
    required this.products,
    this.onProductTap,
  });

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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConstant.headlineTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextContext(
          text: 'Top Picks For You',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstant.headlineTextColor,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              border: Border(
                bottom: BorderSide(
                  color: ColorConstant.borderColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 20,
                  color: ColorConstant.primaryColor,
                ),
                const SizedBox(width: 8),
                TextContext(
                  text: 'Recommended for you',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.bodyTextColor,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextContext(
                    text: '${products.length} items',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorConstant.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: ColorConstant.placeholderColor,
            ),
            const SizedBox(height: 16),
            TextContext(
              text: 'No Top Picks Available',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstant.bodyTextColor,
            ),
            TextContext(
              text: 'Check back later for personalized recommendations!',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorConstant.placeholderColor,
            ),
          ],
        ),
      )
          : Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: size.height * 0.02,
            crossAxisSpacing: size.width * 0.04,
            childAspectRatio: cardWidth / (size.height * 0.30),
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              width: cardWidth,
              variant: ProductCardVariant.pick,
              onTap: () {
                onProductTap?.call(product);
              },
            );
          },
        ),
      ),
    );
  }
}